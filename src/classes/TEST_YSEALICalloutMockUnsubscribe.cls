global class TEST_YSEALICalloutMockUnsubscribe implements HttpCalloutMock {
  global HttpResponse respond( HTTPRequest req )
  {
    HttpResponse res = new HttpResponse();
    res.setStatus( 'OK' );
    res.setStatusCode( 200 );
    String jsonResp = '{"success_count": 1,"error_count": 1,"errors": [{"email": {"email": "pathaninp@aol.com","euid": "abcd13455","leid": "12457bcfca"},"code": 215,"error": "pathaninp@aol.com is not subscribed"}]}';
    res.setBody(jsonResp);
    return res;
  }
}