global with sharing class SARF_CustomFormURLs implements Site.UrlRewriter {
    
    
    String amsp_portal_login_form = '/sarf';
    String amsp_new = '/Portal_Request';
    
    global PageReference mapRequestUrl(PageReference myFriendlyUrl){
        System.debug('Entered this method!!!@@@');
        String url = myFriendlyUrl.getUrl();
        if(url.startsWith(amsp_portal_login_form)){
            String name = url.substring(amsp_portal_login_form.length(), url.length());
        }
        return new PageReference(amsp_new);
    }
    
    global List<PageReference> generateUrlFor(List<PageReference> mySalesforceUrls){
        return null;
    }
}