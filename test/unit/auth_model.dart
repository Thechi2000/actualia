import 'package:actualia/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordSignin extends FakeGoTrueClient {
  @override
  Future<AuthResponse> signInWithPassword(
      {String? email,
      String? phone,
      required String password,
      String? captchaToken}) {
    expect(email, equals("test@actualia.org"));
    expect(password, equals("1234"));
    return Future.value(AuthResponse(
        session: Session(
            accessToken: "",
            tokenType: "",
            user: const User(
                id: "1234",
                appMetadata: {},
                userMetadata: {},
                aud: "",
                createdAt: "")),
        user: const User(
            id: "1234",
            appMetadata: {},
            userMetadata: {},
            aud: "",
            createdAt: "")));
  }
}

class FailingPasswordSignin extends FakeGoTrueClient {
  @override
  Future<AuthResponse> signInWithPassword(
      {String? email,
      String? phone,
      required String password,
      String? captchaToken}) {
    expect(email, equals("test@actualia.org"));
    expect(password, equals("1234"));
    return Future.value(AuthResponse(session: null, user: null));
  }
}

class FakeAccountSignin extends FakeGoTrueClient {
  @override
  Future<AuthResponse> signInWithPassword(
      {String? email,
      String? phone,
      required String password,
      String? captchaToken}) {
    expect(email, equals("actualia@example.com"));
    expect(password, equals("actualia"));
    return Future.value(AuthResponse(
        session: Session(
            accessToken: "",
            tokenType: "",
            user: const User(
                id: "1234",
                appMetadata: {},
                userMetadata: {},
                aud: "",
                createdAt: "")),
        user: const User(
            id: "1234",
            appMetadata: {},
            userMetadata: {},
            aud: "",
            createdAt: "")));
  }
}

class Signout extends FakeGoTrueClient {
  bool hasSignedOut = false;
  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) {
    hasSignedOut = true;
    return Future.value();
  }
}

class FailingSignout extends FakeGoTrueClient {
  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) {
    throw UnimplementedError();
  }
}

class StateChangeSignInEmitter extends FakeGoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => Stream.value(AuthState(
      AuthChangeEvent.signedIn,
      Session(
          accessToken: "",
          tokenType: "",
          user: const User(
              id: "1234",
              appMetadata: {},
              userMetadata: {},
              aud: "",
              createdAt: ""))));
}

class StateChangeSignOutEmitter extends FakeGoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => Stream.fromIterable([
        AuthState(
            AuthChangeEvent.signedIn,
            Session(
                accessToken: "",
                tokenType: "",
                user: const User(
                    id: "1234",
                    appMetadata: {},
                    userMetadata: {},
                    aud: "",
                    createdAt: ""))),
        AuthState(AuthChangeEvent.signedOut, null)
      ]);
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  GoTrueClient client;
  FakeSupabaseClient(this.client);

  @override
  GoTrueClient get auth => client;
}

void main() {
  test("Correctly sign in from auth event", () async {
    AuthModel vm = AuthModel(FakeSupabaseClient(StateChangeSignInEmitter()));
    await Future.delayed(Durations.long2);
    expect(vm.isSignedIn, isTrue);
    expect(vm.user?.id, equals("1234"));
  });

  test("Correctly sign out from auth event", () async {
    AuthModel vm = AuthModel(FakeSupabaseClient(StateChangeSignOutEmitter()));
    await Future.delayed(Durations.long2);
    expect(vm.isSignedIn, isFalse);
    expect(vm.user, isNull);
  });

  test("Correctly signs in with password", () async {
    AuthModel vm = AuthModel(FakeSupabaseClient(PasswordSignin()));
    expect(await vm.signInWithEmail("test@actualia.org", "1234"), isTrue);
  });

  test("Handle password sign in failure", () async {
    AuthModel vm = AuthModel(FakeSupabaseClient(FailingPasswordSignin()));
    expect(await vm.signInWithEmail("test@actualia.org", "1234"), isFalse);
  });

  test("Correctly signs in with fake account", () async {
    AuthModel vm = AuthModel(FakeSupabaseClient(FakeAccountSignin()));
    expect(await vm.signInWithFakeAccount(), isTrue);
  });

  test("Correctly signs out", () async {
    final c = Signout();
    AuthModel vm = AuthModel(FakeSupabaseClient(c));

    expect(await vm.signOut(), isTrue);
    expect(c.hasSignedOut, isTrue);
  });

  test("Handle signs out failure", () async {
    AuthModel vm = AuthModel(FakeSupabaseClient(FailingSignout()));
    expect(await vm.signOut(), isFalse);
  });
}
