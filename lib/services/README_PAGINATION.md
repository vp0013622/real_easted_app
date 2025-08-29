# Pagination Service for Flutter App

This service provides client-side pagination functionality to improve app performance by loading data in smaller chunks instead of all at once.

## Features

- **Client-side pagination**: Load data in batches of configurable size
- **Auto-loading**: Automatically load more data when user scrolls near the bottom
- **Loading indicators**: Show loading state while fetching more data
- **Filter support**: Works with filtered lists
- **Reusable**: Can be used across different pages in the app

## How It Works

1. **Initial Load**: Load first batch of data (e.g., 20 items)
2. **Scroll Detection**: Monitor scroll position to detect when user is near bottom
3. **Auto-load**: Automatically load next batch when needed
4. **Performance**: Only render visible items + small buffer

## Usage Examples

### Basic Implementation

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMoreData = true;
  static const int itemsPerPage = 20;
  int currentPage = 0;
  
  List<MyModel> items = [];
  List<MyModel> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoadingMore || !hasMoreData) return;
    
    setState(() {
      isLoadingMore = true;
    });

    try {
      // Load next batch of data
      final nextBatch = await _fetchNextBatch();
      if (nextBatch.isNotEmpty) {
        setState(() {
          items.addAll(nextBatch);
          filteredItems = _applyFilters(items);
          currentPage++;
        });
      } else {
        setState(() {
          hasMoreData = false;
        });
      }
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredItems.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredItems.length) {
          return _buildLoadingIndicator();
        }
        
        return _buildItemCard(filteredItems[index]);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Loading more items...'),
          ],
        ),
      ),
    );
  }
}
```

### Using the PaginationService Class

```dart
import 'package:inhabit_realties/services/pagination_service.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with PaginationMixin<MyModel> {
  List<MyModel> allItems = [];
  List<MyModel> filteredItems = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize pagination
    initPagination(
      itemsPerPage: 20,
      allItems: allItems,
      filteredItems: filteredItems,
    );
    
    _loadData();
  }

  Future<void> _loadData() async {
    // Load your data here
    final data = await _fetchData();
    
    setState(() {
      allItems = data;
      filteredItems = data;
    });
    
    // Update pagination with new data
    updateFilteredItems(filteredItems);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController, // From PaginationMixin
      itemCount: paginationService.currentPageItems.length + 
                 (paginationService.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == paginationService.currentPageItems.length) {
          return PaginationLoadingIndicator(
            isLoading: paginationService.isLoadingMore,
            message: 'Loading more items...',
          );
        }
        
        return _buildItemCard(paginationService.currentPageItems[index]);
      },
    );
  }
}
```

## Benefits

1. **Better Performance**: Only load and render what's needed
2. **Reduced Memory Usage**: Don't keep all data in memory
3. **Faster Initial Load**: Show first batch quickly
4. **Better User Experience**: Smooth scrolling with auto-loading
5. **Reduced API Calls**: Load data in batches instead of all at once

## Configuration

- **Items Per Page**: Configure how many items to load per batch (default: 20)
- **Scroll Threshold**: How close to bottom before loading more (default: 200px)
- **Loading Delay**: Simulate API call delay (default: 500ms)

## Pages Using Pagination

- ✅ **Leads Page**: Implemented with basic pagination
- ✅ **Properties Page**: Implemented with basic pagination
- 🔄 **Users Page**: Ready for pagination implementation
- 🔄 **Documents Page**: Ready for pagination implementation
- 🔄 **Meeting Schedule Page**: Ready for pagination implementation

## Next Steps

1. **Real API Integration**: Replace simulated loading with actual API calls
2. **Cache Management**: Implement data caching for better performance
3. **Error Handling**: Add proper error handling for failed loads
4. **Pull to Refresh**: Integrate with existing refresh functionality
5. **Search Optimization**: Optimize search with pagination

## Notes

- This is **client-side pagination** - all data is loaded from the backend initially
- For true server-side pagination, modify the service to make API calls with page/limit parameters
- The current implementation shows the structure and can be easily extended
- Performance improvements will be most noticeable with large datasets (100+ items)
