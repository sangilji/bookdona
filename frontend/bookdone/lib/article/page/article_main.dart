import 'dart:ffi';

import 'package:bookdone/article/model/article_data.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:bookdone/search/model/book.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat/model/chat.dart';
import '../../chat/page/chat_room.dart';

class ArticleMain extends HookConsumerWidget {
  const ArticleMain({super.key, required this.isbn, required this.id});

  final String isbn;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    final articleData = useState<ArticleData?>(null);
    final bookData = useState<BookData?>(null);

    final userNickname = useState<String>("");
    final userId = useState<int>(0);

    final tradeIdFromServer = useState<int>(0);

    Future<ArticleData> getArticleInfo() async {
      ArticleRespByid data = await restClient.getArticleById(id);
      ArticleData articleInfo = data.data;
      print('아티클인포여기얌여기############ ${articleInfo}');
      return articleInfo;
    }

    Future<BookData> getBookInfo() async {
      BookDetail data = await restClient.getDetailBook(isbn);
      BookData bookInfo = data.data;
      print('북인포여기얌여기############ ${bookInfo}');
      return bookInfo;
    }

    useEffect(() {
      Future<void> init() async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        userNickname.value = pref.getString('nickname')!;
        userId.value = pref.getInt('userId')!;
      }

      init();

      getArticleInfo().then((articleInfo) {
        articleData.value = articleInfo;
      }).catchError((error) {
        print(error);
      });
      getBookInfo().then((bookInfo) {
        bookData.value = bookInfo;
      }).catchError((error) {
        print(error);
      });
      return null;
    }, []);

    void confirmAndNavigate(BuildContext currentContext) async {
      final restClient = ref.read(restApiClientProvider);

      try {
        var tradeResponseDto =
            await restClient.createTrade(articleData.value!.id, userId.value);
        int tradeIdFromServer = tradeResponseDto.data;
        if (tradeResponseDto.data == null) {
          return;
        }

        tradeIdFromServer = tradeResponseDto.data!;
        // 관련 ChatRoomRequest 객체 작성
        var chatRoomRequest = ChatRoomRequest(
          user1: userNickname.value,
          user2: articleData.value!.nickname,
          tradeId: tradeIdFromServer,
          isbn: articleData.value!.isbn,
        );

        // 채팅방 생성 API 호출
        await restClient.createChatRoom(chatRoomRequest.toJson());

        // 페이지 이동
        ChatRoomRoute(
          tradeId: tradeIdFromServer,
          nameWith: articleData.value!.nickname,
          bookName: bookData.value!.title,
          lastChat: "",
          isbn: articleData.value!.isbn,
        ).push(context);
      } catch (error) {
        print('Error on confirmation: $error');
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Error when trying to navigate: $error'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 10),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                CachedNetworkImage(
                  width: 200,
                  imageUrl:
                      bookData.value != null ? bookData.value!.titleUrl : '',
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  bookData.value != null ? bookData.value!.title : '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(thickness: 1, height: 1),
                      SizedBox(
                        height: 20,
                      ),
                      if (articleData.value != null)
                        articleData.value!.historyResponseList.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  print(id);
                                  HistoryRoute(
                                    donationId: id,
                                    title: bookData.value != null
                                        ? bookData.value!.title
                                        : '',
                                    titleUrl: bookData.value != null
                                        ? bookData.value!.titleUrl
                                        : '',
                                  ).push(context);
                                },
                                child: Text(
                                  '${articleData.value!.historyResponseList.length}개의 히스토리',
                                ),
                              )
                            : Text('히스토리가 없습니다'),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(thickness: 1, height: 1),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "기부자의 글",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (articleData.value != null)
                        Text(
                          articleData.value!.content,
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      articleData.value != null
                          ? Container(
                              // margin: EdgeInsets.all(10),
                              child: GridView.builder(
                                padding: EdgeInsets.all(0),
                                shrinkWrap: true,
                                itemCount:
                                    articleData.value!.imageUrlList.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, //1 개의 행에 보여줄 사진 개수
                                  childAspectRatio: 1 / 1, //사진 의 가로 세로의 비율
                                  mainAxisSpacing: 10, //수평 Padding
                                  crossAxisSpacing: 10, //수직 Padding
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  // print(
                                  //     '${articleData.value!.imageUrlList[index]}');
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        fit:
                                            BoxFit.cover, //사진을 크기를 상자 크기에 맞게 조절
                                        image: NetworkImage(articleData
                                            .value!.imageUrlList[index]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(' '),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(thickness: 1, height: 1),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "책 정보",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (bookData.value != null)
                        Text(
                          bookData.value!.author,
                        ),
                      Text(
                        bookData.value != null ? bookData.value!.publisher : '',
                      ),
                      Text(
                        bookData.value != null ? bookData.value!.isbn : '',
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.brown.shade200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 17),
                backgroundColor: Colors.brown.shade200,
                foregroundColor: Colors.white,
                shape: BeveledRectangleBorder()),
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: const Text(
                    '나눔 신청',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  content: const Text('나눔을 신청할까요?\n기부자와의 채팅이 시작됩니다'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        // 이 함수를 호출할 때 적절한 context를 전달합니다.
                        // 비동기 함수가 완료될 때까지 기다릴 필요가 없습니다.
                        confirmAndNavigate(context);
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              '나눔 요청하기',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}