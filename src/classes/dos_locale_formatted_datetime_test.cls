/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class dos_locale_formatted_datetime_test {

    static testMethod void test_logic() {
		//test for English (United States) format
		List<User> userUpdate = new List<User>(); //list for holding user updates
		userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'en_US')); //set the locale for the running user to English (United States)
		update userUpdate; //make the update
		dos_controller_locale_formatted_datetime controller = new dos_controller_locale_formatted_datetime();
		controller.date_time = DateTime.valueOf('2007-01-01 2:35:21'); //set the datetime variable to 1 January 2007
		controller.userId = UserInfo.getUserId();
		String test_value = controller.getTimeZoneValue(); //run the logic and format the datetime value
		System.assertEquals('1/1/2007 2:35 AM', test_value); //validate the results
		
		//now test for Arabic (Saudi Arabia) format
		userUpdate.clear(); //remove all user sobjects from the userUpdate List
		userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'ar_SA')); //set the locale for the running user to Arabic (Saudi Arabia)
		update userUpdate; //make the update
		controller.date_time = DateTime.valueOf('2005-03-07 5:02:21'); //set the datetime variable to 7 March 2005
		test_value = controller.getTimeZoneValue(); //run the logic and format the datetime value
		//System.assertEquals('07/03/2005 05:02 AM', test_value); //validate the results

		//now test for Chinese (Taiwan) format
		userUpdate.clear(); //remove all user sobjects from the userUpdate List
		userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'zh_TW')); //set the locale for the running user to Chinese (Taiwan)
		update userUpdate; //make the update
		controller.date_time = DateTime.newInstance(2011, 1, 3, 12, 41, 15); //set the datetime variable to 3 January 2011
		test_value = controller.getTimeZoneValue(); //run the logic and format the datetime value
		//System.assertEquals('2011/1/3 PM 12:41', test_value); //validate the results
	}
}