#include <inc/memlayout.h>
#include <kern/kheap.h>
#include <kern/memory_manager.h>

//2016: NOTE: All kernel heap allocations are multiples of PAGE_SIZE (4KB)
struct Size_Address_KHeap{
	uint32 size;
	void *virtualAddress;
	uint32 empty;
};

uint32 virtualAddresses[1<<20];

struct Size_Address_KHeap allocatedHAddresses[(KERNEL_HEAP_MAX-KERNEL_HEAP_START+1)/PAGE_SIZE];
uint32 idx = 0;

void *firstFreeVAInKHeap  = (void*)(KERNEL_HEAP_START);
void* kmallocFirstFit(unsigned int size)
{
	int i, j,r = 0,freedFrameFound=0,firstFitIndex,freeSizeSum=0,count=0;
	void* retVal,*writeAt;
	size = (size+PAGE_SIZE-1)/PAGE_SIZE;

	if(firstFreeVAInKHeap >= (void*)KERNEL_HEAP_MAX-size*PAGE_SIZE)//If size doesn't fit
	{
		for(i=0;i<idx;i++)//Check previous allocations
		{//If size fits in that allocation && it's been freed then write inside it.
			if(allocatedHAddresses[i].empty==1)
			{
				freeSizeSum+=allocatedHAddresses[i].size;
				j=i+1;
				count++;
				while(j<idx&&freeSizeSum<size&&allocatedHAddresses[j].empty==1)
				{
					freeSizeSum+=allocatedHAddresses[j].size;
					j++;
					count++;
				}
				if(freeSizeSum>=size){//merge these frames
					firstFitIndex=i;
					writeAt=allocatedHAddresses[i].virtualAddress;
					freedFrameFound=1;
					break;
				}
			}
		}
		if(!freedFrameFound)
			return NULL;
	}
	if(!freedFrameFound)writeAt=firstFreeVAInKHeap;
	retVal = writeAt;
	for(i = 0; i < size; i++){
		struct Frame_Info *ptr;
		if((r = allocate_frame(&ptr)) < 0) return NULL;
		map_frame(ptr_page_directory, ptr, writeAt, PERM_PRESENT|PERM_WRITEABLE);
		virtualAddresses[to_physical_address(ptr)/PAGE_SIZE] = (uint32)writeAt;
		writeAt += PAGE_SIZE;
	}
	if(freedFrameFound){
		// update
		allocatedHAddresses[firstFitIndex].size=size;
		for(i=0;i<count;i++){
			allocatedHAddresses[firstFitIndex+i].empty=0;
		}
	}
	else{
		firstFreeVAInKHeap=writeAt;
		allocatedHAddresses[idx].virtualAddress = retVal;
		allocatedHAddresses[idx].size = size;
		idx++;
	}
	return retVal;
}

void *kmallocBestFit(unsigned int size)
{
	int i, j, r = 0, freedFrameFound=0, bestFitIndex, freeSizeSum=0, count=0;
	void* retVal,*writeAt;
	size = (size+PAGE_SIZE-1)/PAGE_SIZE;
	uint32 difference=1e9;

	for(i=0;i<idx;i++)//Check previous allocations
	{//If size fit's in that allocation && it's been freed then write inside it.
		if(allocatedHAddresses[i].empty==1)
		{
			freeSizeSum+=allocatedHAddresses[i].size;
			j=i+1;
			count++;
			while(j<idx&&freeSizeSum<size&&allocatedHAddresses[j].empty==1)
			{
				freeSizeSum+=allocatedHAddresses[j].size;
				j++;
				count++;
			}

			if(freeSizeSum>=size &&freeSizeSum-size<difference)
			{
				bestFitIndex=i;
				writeAt=allocatedHAddresses[i].virtualAddress;
				freedFrameFound=1;
				difference=freeSizeSum-size;
			}

		}
	}
	if(firstFreeVAInKHeap >= (void*)KERNEL_HEAP_MAX-size*PAGE_SIZE && !freedFrameFound)
		return NULL;

	if(!freedFrameFound)writeAt=firstFreeVAInKHeap;
	retVal = writeAt;
	for(i = 0; i < size; i++){
		struct Frame_Info *ptr;
		if((r = allocate_frame(&ptr)) < 0) return NULL;
		map_frame(ptr_page_directory, ptr, writeAt, PERM_PRESENT|PERM_WRITEABLE);
		virtualAddresses[to_physical_address(ptr)/PAGE_SIZE] = (uint32)writeAt;
		writeAt += PAGE_SIZE;
	}
	if(freedFrameFound){
		// update
		allocatedHAddresses[bestFitIndex].size=size;
		for(i=0;i<count;i++)
			allocatedHAddresses[bestFitIndex+i].empty=0;
	}
	else{
		firstFreeVAInKHeap=writeAt;
		allocatedHAddresses[idx].virtualAddress = retVal;
		allocatedHAddresses[idx].size = size;
		idx++;
	}
	return retVal;
}

void* kmalloc(unsigned int size)
{
	//return kmallocFirstFit(size);
	//return kmallocBestFit(size);

	//Original kmalloc Code
	size = (size+PAGE_SIZE-1)/PAGE_SIZE;
	if(firstFreeVAInKHeap >= (void*)KERNEL_HEAP_MAX-size*PAGE_SIZE)
		return NULL;

	int i, r = 0;
	void* retVal = firstFreeVAInKHeap;

	for(i = 0; i < size; i++){
		struct Frame_Info *ptr;
		if((r = allocate_frame(&ptr)) < 0) return NULL;
		map_frame(ptr_page_directory, ptr, firstFreeVAInKHeap, PERM_PRESENT|PERM_WRITEABLE);
		virtualAddresses[to_physical_address(ptr)/PAGE_SIZE] = (uint32)firstFreeVAInKHeap;
		firstFreeVAInKHeap += PAGE_SIZE;
	}
	allocatedHAddresses[idx].virtualAddress = retVal;
	allocatedHAddresses[idx].size = size;
	allocatedHAddresses[idx].empty=0;
	idx++;

	//cprintf("Allocating %x\n",retVal);
	return retVal;

	//TODO: [PROJECT 2016 - Kernel Dynamic Allocation/Deallocation] kmalloc()
	// Wptrrite your code here, remove the panic and write your code
	//panic("kmalloc() is not implemented yet...!!");

	//NOTE: Allocation is continuous increasing virtual address
	//NOTE: All kernel heap allocations are multiples of PAGE_SIZE (4KB)
	//refer to the project documentation for the detailed steps


	//TODO: [PROJECT 2016 - BONUS1] Implement a Kernel allocation strategy
	// Instead of the continuous allocation/deallocation, implement one of
	// the strategies NEXT FIT, BEST FIT, .. etc


	//change this "return" according to your answer
	//return 0;
}

void kfree(void *virtual_address)
{
	uint32 i, size=0, index;
	for(i = 0; i < (KERNEL_HEAP_MAX-KERNEL_HEAP_START+1)/PAGE_SIZE;i++){
		if(allocatedHAddresses[i].virtualAddress==virtual_address){
			size=allocatedHAddresses[i].size;
			index=i;
			break;
		}
	}
	for(i = 0; i < size; i++){
		virtualAddresses[kheap_physical_address((uint32)virtual_address)/PAGE_SIZE]=0;
		unmap_frame(ptr_page_directory,virtual_address);
		virtual_address+=PAGE_SIZE;
	}


	allocatedHAddresses[index].empty=1;

	//TODO: [PROJECT 2016 - Kernel Dynamic Allocation/Deallocation] kfree()
	// Write your code here, remove the panic and write your code
	//panic("kfree() is not implemented yet...!!");

	//get the size of the given allocation using its address
	//refer to the project documentation for the detailed steps

	//TODO: [PROJECT 2016 - BONUS1] Implement a Kernel allocation strategy
	// Instead of the continuous allocation/deallocation, implement one of
	// the strategies NEXT FIT, BEST FIT, .. etc
	tlbflush();
	return;
}

unsigned int kheap_virtual_address(unsigned int physical_address)
{
	return virtualAddresses[physical_address/PAGE_SIZE];

	//TODO: [PROJECT 2016 - Kernel Dynamic Allocation/Deallocation] kheap_virtual_address()
	// Write your code here, remove the panic and write your code
	//panic("kheap_virtual_address() is not implemented yet...!!");

	//return the virtual address corresponding to given physical_address
	//refer to the project documentation for the detailed steps

	//change this "return" according to your answer
}

unsigned int kheap_physical_address(unsigned int virtual_address)
{
	uint32 *pageTable;
	get_page_table(ptr_page_directory,(void*)virtual_address,&pageTable);
	uint32 physical= (pageTable[PTX(virtual_address)]>>12);
	return physical * PAGE_SIZE;
	//TODO: [PROJECT 2016 - Kernel Dynamic Allocation/Deallocation] kheap_physical_address()
	// Write your code here, remove the panic and write your code
	//panic("kheap_physical_address() is not implemented yet...!!");

	//return the physical address corresponding to given virtual_address
	//refer to the project documentation for the detailed steps

	//change this "return" according to your answer
	//return 0;
}
