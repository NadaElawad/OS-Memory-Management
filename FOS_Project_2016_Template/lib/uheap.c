
#include <inc/lib.h>
/*
 * Simple malloc()
 *
 * The address space for the dynamic allocation is
 * from "USER_HEAP_START" to "USER_HEAP_MAX"-1
 * Pages are allocated ON 4KB BOUNDARY
 * On succeed, return void pointer to the allocated space
 * return NULL if
 *	-there's no suitable space for the required allocation
 */

// malloc()
//	This function use both NEXT FIT and BEST FIT strategies to allocate space in heap
//  with the given size and return void pointer to the start of the allocated space

//	To do this, we need to switch to the kernel, allocate the required space
//	in Page File then switch back to the user again.
//
//	We can use sys_allocateMem(uint32 virtual_address, uint32 size); which
//		switches to the kernel mode, calls allocateMem(struct Env* e, uint32 virtual_address, uint32 size) in
//		"memory_manager.c", then switch back to the user mode here
//	the allocateMem function is empty, make sure to implement it.
struct Size_Address_UHeap{
	uint32 size;
	uint32 virtualAddress;
};

struct Size_Address_UHeap sizeOfVAs[(USER_HEAP_MAX-USER_HEAP_START)/PAGE_SIZE];
bool UHeap_Tracker[(USER_HEAP_MAX - USER_HEAP_START)/PAGE_SIZE] = {0};

uint32 currentAddressForNextFitPlacement = USER_HEAP_START;
uint32 generalAddress = USER_HEAP_START;
void* malloc(uint32 size)
{
	size = ROUNDUP(size, PAGE_SIZE);
	if(sys_isUHeapPlacementStrategyNEXTFIT())
	{
		uint32 k = (USER_HEAP_MAX-USER_HEAP_START)/PAGE_SIZE, i = generalAddress, j;
		uint32 currentSize = 0;
		bool flag = 0, found = 0;
		while(k != 0)
		{
			if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 1){
				currentSize += PAGE_SIZE;
				k--;
				i+=PAGE_SIZE;
			}
			else if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 0){
				flag = 1;
				j = i;
				currentSize += PAGE_SIZE;
				k--;
				i+=PAGE_SIZE;
			}
			else
			{
				if(currentSize >= size){
					generalAddress = j;
					found = 1;
					break;
				}
				k-=UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE];
				i+=PAGE_SIZE*UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE];
				flag = 0;
				currentSize = 0;
			}
			if(currentSize >= size){
				generalAddress = j;
				found = 1;
				break;
			}
			if(i >= USER_HEAP_MAX){
				currentSize = 0;
				flag = 0;
				i = USER_HEAP_START;
			}
		}
		if(found == 0 && currentSize >= size) generalAddress = j;
		else if(found == 0) return NULL;
	}
	else if(sys_isUHeapPlacementStrategyFIRSTFIT())
	{
		uint32 i, j;
		uint32 currentSize = 0;
		generalAddress = USER_HEAP_START;
		bool flag = 0,found=0;
		for(i = USER_HEAP_START; i < USER_HEAP_MAX; )
		{
			if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 1){
				currentSize += PAGE_SIZE;
				i+=PAGE_SIZE;
			}
			else if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 0){
				flag = 1;
				j = i;
				currentSize += PAGE_SIZE;
				i+=PAGE_SIZE;
			}
			else
			{
				if(currentSize >= size){
					generalAddress = j;
					found = 1;
					break;
				}
				i+=PAGE_SIZE*UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE];
				flag = 0;
				currentSize = 0;
			}
		}
		if(found == 0 && currentSize >= size) generalAddress=j;
		else if(found == 0) return NULL;
	}
	else if(sys_isUHeapPlacementStrategyBESTFIT())
	{
		uint32 minViableSize = USER_HEAP_MAX - USER_HEAP_START;
		uint32 i, j;
		uint32 currentSize = 0;
		generalAddress = USER_HEAP_START;
		bool flag = 0,found=0;
		for(i = USER_HEAP_START; i < USER_HEAP_MAX;)
		{
			if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 1){
				currentSize += PAGE_SIZE;
				i+=PAGE_SIZE;
			}
			else if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 0){
				flag = 1;
				j = i;
				currentSize += PAGE_SIZE;
				i+=PAGE_SIZE;
			}
			else
			{
				if(currentSize >= size && minViableSize > currentSize){
					generalAddress = j;
					minViableSize = currentSize;
					found = 1;
				}
				i+=PAGE_SIZE*UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE];
				flag = 0;
				currentSize = 0;
			}
		}
		if(found == 0 && currentSize >= size) generalAddress=j;
		else if(found == 0) return NULL;
	}
	else if(sys_isUHeapPlacementStrategyWORSTFIT())
	{
		uint32 maxViableSize = 0;
		uint32 i, j;
		uint32 currentSize = 0;
		generalAddress = USER_HEAP_START;
		bool flag = 0,found=0;
		for(i = USER_HEAP_START; i < USER_HEAP_MAX;)
		{
			if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 1){
				currentSize += PAGE_SIZE;
				i+=PAGE_SIZE;
			}
			else if(UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE] == 0 && flag == 0){
				flag = 1;
				j = i;
				currentSize += PAGE_SIZE;
				i+=PAGE_SIZE;
			}
			else
			{
				if(currentSize >= size && maxViableSize < currentSize){
					generalAddress = j;
					maxViableSize = currentSize;
					found = 1;
				}
				i+=PAGE_SIZE*UHeap_Tracker[(i - USER_HEAP_START)/PAGE_SIZE];
				flag = 0;
				currentSize = 0;
			}
		}
		if(found == 0 && currentSize >= size) generalAddress=j;
		else if(found == 0) return NULL;
	}
	uint32 j, i = (generalAddress - USER_HEAP_START)/PAGE_SIZE;
	UHeap_Tracker[i] = size/PAGE_SIZE;
	uint32 ret = generalAddress;
	sys_allocateMem(generalAddress, size);
	sizeOfVAs[(generalAddress - USER_HEAP_START)/PAGE_SIZE].size = size;
	sizeOfVAs[(generalAddress - USER_HEAP_START)/PAGE_SIZE].virtualAddress = generalAddress;
	if(generalAddress+size>=USER_HEAP_MAX) generalAddress=USER_HEAP_START;
	return (void*)ret;
}



// free():
//	This function frees the allocation of the given virtual_address
//	To do this, we need to switch to the kernel, free the pages AND "EMPTY" PAGE TABLES
//	from page file and main memory then switch back to the user again.
//
//	We can use sys_freeMem(uint32 virtual_address, uint32 size); which
//		switches to the kernel mode, calls freeMem(struct Env* e, uint32 virtual_address, uint32 size) in
//		"memory_manager.c", then switch back to the user mode here
//	the freeMem function is empty, make sure to implement it.

void free(void* virtual_address)
{
	uint32 i, j;
	for(i = 0; i < (USER_HEAP_MAX - USER_HEAP_START)/PAGE_SIZE; ++i)
	{
		if((void *)sizeOfVAs[i].virtualAddress == virtual_address)
		{
			uint32 tmp = (sizeOfVAs[i].virtualAddress - USER_HEAP_START)/PAGE_SIZE;
			UHeap_Tracker[tmp] = 0;
			sys_freeMem((uint32)virtual_address, sizeOfVAs[i].size);
			sizeOfVAs[i].virtualAddress = 0;
			sizeOfVAs[i].size = 0;
			break;
		}
	}

	// Write your code here, remove the panic and write your code
	//panic("free() is not implemented yet...!!");

	//get the size of the given allocation using its address
	//you need to call sys_freeMem()
}


//=================================================================================//
//============================== BONUS FUNCTION ===================================//
//=================================================================================//
// realloc():

//	Attempts to resize the allocated space at "virtual_address" to "new_size" bytes,
//	possibly moving it in the heap.
//	If successful, returns the new virtual_address, in which case the old virtual_address must no longer be accessed.
//	On failure, returns a null pointer, and the old virtual_address remains valid.

//	A call with virtual_address = null is equivalent to malloc().
//	A call with new_size = zero is equivalent to free().

//  Hint: you may need to use the sys_moveMem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
//		which switches to the kernel mode, calls moveMem(struct Env* e, uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
//		in "memory_manager.c", then switch back to the user mode here
//	the moveMem function is empty, make sure to implement it.

void *realloc(void *virtual_address, uint32 new_size)
{
	//TODO: [PROJECT 2016 - BONUS4] realloc() [User Side]
	// Write your code here, remove the panic and write your code

	panic("realloc() is not implemented yet...!!");

}

