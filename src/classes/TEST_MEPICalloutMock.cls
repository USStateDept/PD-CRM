@isTest
global class TEST_MEPICalloutMock implements HttpCalloutMock
{
  global HttpResponse respond( HTTPRequest req )
  {
    HttpResponse res = new HttpResponse();
    res.setStatus( 'OK' );
    res.setStatusCode( 200 );
    res.setBody( '{ "total": 1, "data": [ { "id": "d2457bcfca", "web_id": 282889, "name": "Salesforce", "date_created": "2014-02-14 18:04:24", "email_type_option": false, "use_awesomebar": true, "default_from_name": "Ikjae Park", "default_from_email": "parki2@state.gov", "default_subject": "Salesforce - Testing", "default_language": "en", "list_rating": 0, "subscribe_url_short": "http://eepurl.com/OHwOn", "subscribe_url_long": "http://state.us3.list-manage.com/subscribe?u=ae561a12869798ead43e29e8e&id=d2457bcfca", "beamer_address": "us3-602561ef16-3afefd74b3@inbound.mailchimp.com", "visibility": "pub", "stats": { "member_count": 4, "unsubscribe_count": 0, "cleaned_count": 0, "member_count_since_send": 42, "unsubscribe_count_since_send": 0, "cleaned_count_since_send": 0, "campaign_count": 1, "grouping_count": 0, "group_count": 0, "merge_var_count": 3, "avg_sub_rate": 2, "avg_unsub_rate": 0, "target_sub_rate": 0, "open_rate": 0, "click_rate": 0, "date_last_campaign": null }, "modules": [] } ], "errors": [] }' );
    return res;
  }
}