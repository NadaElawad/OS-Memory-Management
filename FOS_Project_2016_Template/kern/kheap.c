#include <inc/memlayout.h>
#include <kern/kheap.h>
#include <kern/memory_manager.h>

//2016: NOTE: All kernel heap allocations are multiples of PAGE_SIZE (4KB)
struct Size_Address_KHeap{
	uint32 size;
	void *virtualAddress;
};

uint32 virtualAddresses[1<<20];
struct Size_Address_KHeap allocatedHAddresses[(KERNEL_HEAP_MAX-KERNEL_HEAP_START)/PAGE_SIZE];
uint32 idx = 0;
void *firstFreeVAInKHeap  = (void*)(KERNEL_HEAP_START);

void* kmalloc(unsigned int size)
{
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
	idx++;
	return retVal;

	//TODO: [PROJECT 2016 - BONUS1] Implement a Kernel allocation strategy
	// Instead of the continuous allocation/deallocation, implement one of
	// the strategies NEXT FIT, BEST FIT, .. etc
}

void kfree(void *virtual_address)
{
	uint32 i, size=0, index;
	for(i = 0; i < (KERNEL_HEAP_MAX-KERNEL_HEAP_START)/PAGE_SIZE;i++){
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
	allocatedHAddresses[index].size=0;
	allocatedHAddresses[index].virtualAddress=0;

	//TODO: [PROJECT 2016 - BONUS1] Implement a Kernel allocation strategy
	// Instead of the continuous allocation/deallocation, implement one of
	// the strategies NEXT FIT, BEST FIT, .. etc
	tlbflush();
	return;
}

unsigned int kheap_virtual_address(unsigned int physical_address)
{
	return virtualAddresses[physical_address/PAGE_SIZE];

	//return the virtual address corresponding to given physical_address
	//refer to the project documentation for the detailed steps

}

unsigned int kheap_physical_address(unsigned int virtual_address)
{
	uint32 *pageTable;
	get_page_table(ptr_page_directory,(void*)virtual_address,&pageTable);
	uint32 physical= (pageTable[PTX(virtual_address)]>>12);
	return physical * PAGE_SIZE;

	//return the physical address corresponding to given virtual_address
	//refer to the project documentation for the detailed steps
}
