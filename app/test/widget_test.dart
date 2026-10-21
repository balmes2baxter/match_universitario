import 'package:flutter_test/flutter_test.dart';

import 'package:match_universitario_app/main.dart';
import 'package:match_universitario_app/models/posting.dart';
import 'package:match_universitario_app/state/app_state.dart';

void main() {
  testWidgets('App arranca en el Landing de Uniguajira y navega al Tablero', (tester) async {
    await tester.pumpWidget(const MatchUniversitarioApp());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Universidad de La Guajira'),
      findsWidgets,
    );
    expect(find.text('Empieza a hacer Match ya'), findsOneWidget);

    await tester.tap(find.text('Empieza a hacer Match ya'));
    await tester.pumpAndSettle();

    expect(find.text('Tablero de Oportunidades'), findsOneWidget);
    expect(find.text('Nueva publicación'), findsNothing);
  });

  test('Marcar "Me interesa" agrega al usuario en la publicación', () {
    final state = AppState();
    final post = state.feed.firstWhere((p) => !state.isOwner(p));
    final before = post.applicantCount;

    state.applyToPost(post);
    final updated = state.feed.firstWhere((p) => p.id == post.id);

    expect(updated.applicantCount, before + 1);
    expect(state.hasApplied(updated), isTrue);

    // No debe poder aplicar dos veces.
    state.applyToPost(updated);
    final again = state.feed.firstWhere((p) => p.id == post.id);
    expect(again.applicantIds.where((id) => id == state.currentUser.id).length, 1);
  });

  test('Aceptar un interesado revela su contacto', () {
    final state = AppState();
    final myPost = state.myPostings.firstWhere((p) => p.applicantCount > 0);
    final applicant = state.applicantsFor(myPost).first;

    state.acceptApplicant(myPost, applicant.id);
    final updated = state.feed.firstWhere((p) => p.id == myPost.id);

    expect(updated.acceptedIds, contains(applicant.id));
    expect(state.acceptedContactsFor(updated), contains(applicant));
  });

  test('Crear publicación aparece primero en el feed', () {
    final state = AppState();
    final post = state.addPost(
      type: PostType.evento,
      title: 'Feria de ciencia',
      description: 'Evento de prueba con suficiente texto.',
      location: 'Plaza central',
    );

    expect(state.feed.first.id, post.id);
    expect(state.myPostings.map((p) => p.id), contains(post.id));
  });
}
