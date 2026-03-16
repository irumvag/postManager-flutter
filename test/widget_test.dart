import 'package:flutter_test/flutter_test.dart';
import 'package:posts_manager/main.dart';

void main() {
  testWidgets('App smoke test - renders PostsManagerApp', (WidgetTester tester) async {
    await tester.pumpWidget(const PostsManagerApp());
    expect(find.byType(PostsManagerApp), findsOneWidget);
  });
}
