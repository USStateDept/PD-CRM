@isTest
public class DA_TranslateData_Test
{
	public static testmethod void TestTranslateDate()
	{
		datetime tdate = datetime.newInstance( 2013, 12, 12 );
		
		System.assertEquals( '12 December 2013', DA_TranslateData.TranslateDate( tdate, 'English' ));
		System.assertEquals( '12 diciembre 2013', DA_TranslateData.TranslateDate( tdate, 'Spanish' ));
		System.assertEquals( '12 décembre 2013', DA_TranslateData.TranslateDate( tdate, 'French' ));
		System.assertEquals( '12 de dezembro de 2013', DA_TranslateData.TranslateDate( tdate, 'Portuguese' ));
		System.assertEquals( '2013.12.12', DA_TranslateData.TranslateDate( tdate, 'Chinese' ));
		System.assertEquals( '12 декабря 2013 года', DA_TranslateData.TranslateDate( tdate, 'Russian' ));
								System.assertEquals( '12 كانون الأول/ديسمبر 2013', DA_TranslateData.TranslateDate( tdate, 'Arabic' ));
								System.assertEquals( '12 دسامبر 2013', DA_TranslateData.TranslateDate( tdate, 'Persian' ));
								System.assertEquals( '12 دسمبر 2013', DA_TranslateData.TranslateDate( tdate, 'Urdu' ));
	}
	
	
	public static testMethod void TestDetermineProclamation()
	{
		string Language = 'English';
		string Subtype = 'Text';
	
		System.assertEquals( '(Distributed by the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)', DA_TranslateData.DetermineProclamation( 'English', 'Text' ));
		System.assertEquals( '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)', DA_TranslateData.DetermineProclamation( 'English', 'Audio' ));
		
		System.assertEquals( '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)', DA_TranslateData.DetermineProclamation( 'Spanish', 'Text' ));
		System.assertEquals( '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)', DA_TranslateData.DetermineProclamation( 'Spanish', 'Audio' ));
		
		System.assertEquals( '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)', DA_TranslateData.DetermineProclamation( 'French', 'Text' ));
		System.assertEquals( '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)', DA_TranslateData.DetermineProclamation( 'French', 'Byliner' ));
		
		System.assertEquals( '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)', DA_TranslateData.DetermineProclamation( 'Russian', 'Audio' ));
		System.assertEquals( '(Распространено Бюро международных информационных программ Государственного департамента США. Веб-сайт: http://iipdigital.usembassy.gov/iipdigital-ru/index.html )', DA_TranslateData.DetermineProclamation( 'Russian', 'Book' ));

		System.assertEquals( '美国国务院国际信息局 http://iipdigital.usembassy.gov/iipdigital-mgck/index.html', DA_TranslateData.DetermineProclamation( 'Chinese', 'Text' ));
		System.assertEquals( '美国国务院国际信息局 http://iipdigital.usembassy.gov/iipdigital-mgck/index.html', DA_TranslateData.DetermineProclamation( 'Chinese', 'Audio' ));

		System.assertEquals( '(Distribuído pelo Bureau de Programas de Informações Internacionais do Departamento de Estado dos EUA. Site: http://iipdigital.usembassy.gov/iipdigital-pt/index.html)', DA_TranslateData.DetermineProclamation( 'Portuguese', 'Text' ));
		System.assertEquals( '(Produzido pelo Bureau de Programas de Informações Internacionais do Departamento de Estado dos EUA. Site: http://iipdigital.usembassy.gov/iipdigital-pt/index.html)', DA_TranslateData.DetermineProclamation( 'Portuguese', 'Audio' ));
	}
	
	
	public static testMethod void TestReturnCategory()
	{
		string Language = 'English';
		string CatField = 'Africa; Steve; joe;';
		string retVal = '';
		
		System.assertEquals( 'EN/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'English'));
		System.assertEquals( 'EN/REGION/EAP', DA_TranslateData.ReturnCategory(0, 'East Asia & Pacific', 'English'));
		System.assertEquals( 'EN/REGION/EUR', DA_TranslateData.ReturnCategory(0, 'Europe & Eurasia', 'English'));
		System.assertEquals( 'EN/REGION/MENA', DA_TranslateData.ReturnCategory(0, 'Middle East & North Africa', 'English'));
		System.assertEquals( 'EN/REGION/SCA', DA_TranslateData.ReturnCategory(0, 'South & Central Asia', 'English'));
		System.assertEquals( 'EN/REGION/AMERICAS', DA_TranslateData.ReturnCategory(0, 'Western Hemisphere', 'English'));
		System.assertEquals( 'EN/NONE/POTUS', DA_TranslateData.ReturnCategory(0, 'POTUS', 'English'));
		System.assertEquals( 'EN/NONE/SECSTATE', DA_TranslateData.ReturnCategory(0, 'Secretary of State', 'English'));
		System.assertEquals( 'EN/PUBS/TOC', DA_TranslateData.ReturnCategory(0, 'Table of Contents', 'English'));
		System.assertEquals( 'EN/NONE/APEC', DA_TranslateData.ReturnCategory(0, 'APEC', 'English'));
		System.assertEquals( 'EN/REGION/IRAN', DA_TranslateData.ReturnCategory(0, 'Iran', 'English'));
		System.assertEquals( 'EN/REGION/BRAZIL', DA_TranslateData.ReturnCategory(0, 'Brazil', 'English'));
		System.assertEquals( 'EN/REGION/BURMA', DA_TranslateData.ReturnCategory(0, 'Burma', 'English'));
		System.assertEquals( 'EN/REGION/NORTHKOREA', DA_TranslateData.ReturnCategory(0, 'North Korea', 'English'));
		System.assertEquals( 'EN/REGION/USCHINA', DA_TranslateData.ReturnCategory(0, 'U.S.-China Relations', 'English'));
		System.assertEquals( 'EN/REGION/AMERICAS', DA_TranslateData.ReturnCategory(0, 'The Americas', 'English'));
		System.assertEquals( 'EN/REGION/CENTAM', DA_TranslateData.ReturnCategory(0, 'Central America', 'English'));
		System.assertEquals( 'EN/REGION/MEXICO', DA_TranslateData.ReturnCategory(0, 'Mexico', 'English'));
		System.assertEquals( 'EN/REGION/AMERICAS', DA_TranslateData.ReturnCategory(0, 'South America', 'English'));
		System.assertEquals( 'EN/NONE/SOTA', DA_TranslateData.ReturnCategory(0, 'Summit of the Americas', 'English'));
		System.assertEquals( 'EN/NONE/50STATES', DA_TranslateData.ReturnCategory(0, '50 States', 'English'));
		System.assertEquals( '', DA_TranslateData.ReturnCategory(0, 'Africa1', 'English'));
		System.assertEquals( '', DA_TranslateData.ReturnCategory(0, null, 'English'));
		System.assertEquals( '', DA_TranslateData.ReturnCategory(6, 'Africa1;Africa2;Africa13;', 'English'));
		
		System.assertEquals( 'ES/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Spanish'));
		System.assertEquals( 'PT/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Portuguese'));
		System.assertEquals( 'ZH/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Chinese'));
		System.assertEquals( 'RU/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Russian'));
		System.assertEquals( 'AR/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Arabic'));
		System.assertEquals( 'FA/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Persian'));
		System.assertEquals( 'FR/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'French'));
		System.assertEquals( 'UR/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Urdu'));
		System.assertEquals( 'TR/REGION/AFRICA', DA_TranslateData.ReturnCategory(0, 'Africa', 'Turkish'));
	}
	
	
	public static testMethod void TestUpdateBodyURLs()
	{
		System.assertEquals( 'nothing changes', DA_TranslateData.UpdateBodyURLs( 'nothing changes' ));
	}
	
	
	public static testMethod void TestUpdateURL()
	{
		//System.assertEquals( '', DA_TranslateData.UpdateURL( 'http://iipdigital.usembassy.gov/st/english/texttrans/2011/05/20110510161314su2.179682e-02.html' ));
		//System.assertEquals( '', DA_TranslateData.UpdateURL( 'http://iipdigital.usembassy.gov/st/english/texttrans/2011/05/20110510161314su2.179682e-02.htm' ));
		//System.assertEquals( '', DA_TranslateData.UpdateURL( 'http://iipdigital.usembassy.gov/st/english/texttrans/2011/05/20110510161314su2.179682e-02.html' ));
	}
}