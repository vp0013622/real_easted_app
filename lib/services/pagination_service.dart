import 'package:flutter/material.dart';

/// A reusable pagination service that handles client-side pagination
class PaginationService<T> {
  final int itemsPerPage;
  final List<T> allItems;
  final List<T> filteredItems;
  
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  
  PaginationService({
    required this.itemsPerPage,
    required this.allItems,
    required this.filteredItems,
  });

  /// Get the current page
  int get currentPage => _currentPage;
  
  /// Check if there's more data to load
  bool get hasMoreData => _hasMoreData;
  
  /// Check if currently loading more data
  bool get isLoadingMore => _isLoadingMore;
  
  /// Get items for the current page
  List<T> get currentPageItems {
    final startIndex = _currentPage * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredItems.take(endIndex).toList();
  }
  
  /// Get total number of items
  int get totalItems => filteredItems.length;
  
  /// Get total number of pages
  int get totalPages => (totalItems / itemsPerPage).ceil();
  
  /// Check if we can load more data
  bool get canLoadMore => _hasMoreData && !_isLoadingMore;
  
  /// Load next page of data
  Future<void> loadNextPage() async {
    if (!canLoadMore) return;
    
    _isLoadingMore = true;
    
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _currentPage++;
    _hasMoreData = _currentPage < totalPages;
    _isLoadingMore = false;
  }
  
  /// Reset pagination to first page
  void resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
    _isLoadingMore = false;
  }
  
  /// Update filtered items and reset pagination
  void updateFilteredItems(List<T> newFilteredItems) {
    resetPagination();
  }
  
  /// Check if scroll position is near bottom for auto-loading
  bool shouldLoadMore(ScrollController scrollController) {
    if (!canLoadMore) return false;
    
    final position = scrollController.position;
    return position.pixels >= position.maxScrollExtent - 200;
  }
}

/// A mixin that provides pagination functionality to StatefulWidgets
mixin PaginationMixin<T> on State {
  late PaginationService<T> paginationService;
  late ScrollController scrollController;
  
  /// Initialize pagination
  void initPagination({
    required int itemsPerPage,
    required List<T> allItems,
    required List<T> filteredItems,
  }) {
    paginationService = PaginationService<T>(
      itemsPerPage: itemsPerPage,
      allItems: allItems,
      filteredItems: filteredItems,
    );
    
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }
  
  /// Scroll listener for auto-loading
  void _onScroll() {
    if (paginationService.shouldLoadMore(scrollController)) {
      _loadMoreData();
    }
  }
  
  /// Load more data when scrolling
  Future<void> _loadMoreData() async {
    if (paginationService.canLoadMore) {
      await paginationService.loadNextPage();
      if (mounted) {
        setState(() {});
      }
    }
  }
  
  /// Update filtered items
  void updateFilteredItems(List<T> newFilteredItems) {
    paginationService.updateFilteredItems(newFilteredItems);
    if (mounted) {
      setState(() {});
    }
  }
  
  /// Reset pagination
  void resetPagination() {
    paginationService.resetPagination();
    if (mounted) {
      setState(() {});
    }
  }
  
  /// Dispose pagination resources
  void disposePagination() {
    scrollController.dispose();
  }
  
  @override
  void dispose() {
    disposePagination();
    super.dispose();
  }
}

/// A widget that shows a loading indicator for pagination
class PaginationLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final String message;
  
  const PaginationLoadingIndicator({
    super.key,
    required this.isLoading,
    this.message = 'Loading more items...',
  });
  
  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
