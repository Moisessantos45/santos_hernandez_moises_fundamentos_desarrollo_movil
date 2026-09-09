import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripify/main.dart';
import 'package:tripify/presentation/screens/home.dart';
import 'package:tripify/presentation/screens/booking_form_screen.dart';
import 'package:tripify/domain/models/trip.dart';

final List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockHttpClient();
  }
}

HttpClient _createMockHttpClient() {
  final client = _MockHttpClient();
  return client;
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #openUrl) {
      return Future<HttpClientRequest>.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future<HttpClientResponse>.value(_MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return _MockHttpHeaders();
    }
    return null;
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #statusCode) {
      return 200;
    }
    if (invocation.memberName == #contentLength) {
      return _kTransparentImage.length;
    }
    if (invocation.memberName == #listen) {
      final stream = Stream<List<int>>.fromIterable([_kTransparentImage]);
      return stream.listen(
        invocation.positionalArguments[0] as void Function(List<int>)?,
        onDone: invocation.namedArguments[#onDone] as void Function()?,
        onError: invocation.namedArguments[#onError] as Function?,
        cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
      );
    }
    if (invocation.memberName == #compressionState) {
      return HttpClientResponseCompressionState.notCompressed;
    }
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('App loads HomeScreen without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const Main());
    await tester.pump();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Near Me'), findsOneWidget);
  });

  testWidgets('BookingFormScreen loads sections correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const trip = Trip(
      id: 'test-1',
      title: 'Cancún Tropical',
      location: 'Cancún',
      country: 'México',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      rating: 4.8,
      reviewsCount: 120,
      price: 450.0,
      category: 'Playa',
      description: 'Test description',
      highlights: ['Playa', 'Sol'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BookingFormScreen(trip: trip),
      ),
    );
    await tester.pump();

    expect(find.text('Reserva de Viaje'), findsOneWidget);
    expect(find.text('Sección 1 · Información general'), findsOneWidget);
    expect(find.text('Sección 2 · Datos del viajero'), findsOneWidget);
    expect(find.text('Sección 3 · Destino y transporte'), findsOneWidget);
  });
}
