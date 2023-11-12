import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/search/model/book.dart';
import 'package:bookdone/search/service/search_service.dart';
import 'package:bookdone/search/widgets/autocomplete_list.dart';
import 'package:bookdone/search/widgets/search_result_card.dart';
import 'package:bookdone/top/page/top_navigation_bar.dart';
import 'package:bookdone/widgets/floating_register_btn.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';

class SearchMain extends HookConsumerWidget {
  const SearchMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FocusNode textFocus = FocusNode();
    final searchController = useTextEditingController();
    final restClient = ref.read(restApiClientProvider);
    var viewAutoComplete = useState(false);

    var searchedList = useState<List<BookData>>([]);
    var searchText = useState('');
    var autoValue = useState('');
    print(restClient.searchBook('웨않도ㅙㄴ'));
    return GestureDetector(
      onTap: () {
        viewAutoComplete.value = false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 10),
          child: Center(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: searchController,
                        // focusNode: textFocus,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "책 제목 검색",
                          hintStyle:
                              TextStyle(fontSize: 15, decorationThickness: 6),
                          suffixIcon: IconButton(
                              onPressed: () {
                                viewAutoComplete.value = false;
                                searchText.value = searchController.text;
                                // debugPrint(searchText.value);
                                // debugPrint(restClient
                                //     .searchBook(searchText.value)
                                //     .toString());
                              },
                              icon: Icon(Icons.search)),
                          suffixIconColor: Colors.black,
                        ),
                        onChanged: (value) {
                          viewAutoComplete.value = true;
                          autoValue.value = searchController.text;
                        },
                        onSubmitted: (value) {
                          viewAutoComplete.value = false;
                          searchText.value = searchController.text;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        child: searchText.value != ''
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text("${searchText.value} 검색 결과"),
                              )
                            : null),
                    SizedBox(
                      height: 10,
                    ),
                    FutureBuilder(
                      future: restClient.searchBook(searchText.value),
                      builder: (_, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data == null) {
                          return SizedBox.shrink();
                        }

                        final searchedList = snapshot.data!.data;

                        return Expanded(
                          child: ListView.builder(
                            itemCount: searchedList.length,
                            itemBuilder: (_, index) {
                              BookData book = searchedList[index];
                              return SearchResultCard(book: book);
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
                if (viewAutoComplete.value)
                  FutureBuilder<AutoList>(
                    future: restClient.getAutoCompletion(autoValue.value),
                    builder: (_, snapshot) {
                      if (snapshot.data == null) return Container();
                      final autoCompleteList = snapshot.data!.data;

                      return AutocompleteList(autoListData: autoCompleteList);
                    },
                  )
              ],
            ),
          ),
        ),
        // bottomNavigationBar: TopNavigationBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingRegisterBtn(),
      ),
    );
  }
}
