@isTest
global class TEST_MEPICalloutMock2 implements HttpCalloutMock
{
  global HttpResponse respond( HTTPRequest req )
  {
    HttpResponse res = new HttpResponse();
    res.setStatus( 'OK' );
    res.setStatusCode( 200 );
    res.setBody( '{"add_count":4,"adds":[{"email":"ipark@sevatec.com","euid":"da3247087b","leid":"113678713"},{"email":"parki2@state.gov","euid":"f7f99edab6","leid":"113678717"},{"email":"parki3@state.gov","euid":"665e21219a","leid":"113678721"},{"email":"parki4@state.gov","euid":"f4b77209dc","leid":"113678725"}],"update_count":0,"updates":[],"error_count":0,"errors":[]}' );
    return res;
  }
}