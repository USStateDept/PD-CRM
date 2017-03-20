public with sharing class DA_TranslateData
{
   public static string TranslateDate(datetime TDate, string language)
   {
      string RetVal = '';
      List<List<String>> TList = new List<List<String>>
      {
         new String[]{' January ', ' February ', ' March ', ' April ', ' May ', ' June ', ' July ',
            ' August ', ' September ', ' October ', ' November ', ' December '},
         new String[]{' enero ', ' febrero ', ' marzo ', ' abril ', ' mayo ', ' junio ', ' julio ',
            ' agosto ', ' septiembre ', ' octubre ', ' noviembre ', ' diciembre '},
         new String[]{' janvier ', ' février ', ' mars ', ' avril ', ' mai ', ' juin ', ' juillet ',
            ' août ', ' septembre ', ' octobre ', ' novembre ', ' décembre '},
         new String[]{' de janeiro de ', ' de fevereiro de ', ' de março de ', ' de abril de ', 
            ' de maio de ', ' de junho de ', ' de julho de ', ' de agosto de ', ' de setembro de ',
            ' de outubro de ', ' de novembro de ', ' de dezembro de '},
         new String[]{'', '', '', '', '', '', '', '', '', '', '', ''},
         new String[]{' января ', ' февраля ', ' марта ', ' апреля ', ' мая ', ' июня ', ' июля ',
            ' августа ', ' сентября ', ' октября ', ' ноября ', ' декабря '},
         new String[]{' كانون الثاني/يناير ',
         ' شباط/فبراير ',
         ' آذار/مارس ',
         ' نيسان/إبريل ',
         ' أيار/مايو ',
         ' حزيران/يونيو ',
         ' تموز/يوليو ',
         ' آب/أغسطس ',
         ' ايلول/سبتمبر ',
         ' تشرين الأول/أكتوبر ',
         ' تشرين الثاني/نوفمبر ',
         ' كانون الأول/ديسمبر '},//this displays funny on a single line
         new String[]
         {' ژانويه ',
          ' فوريه ',
          ' مارس ',
          ' آوريل ',
          ' مه ',
          ' ژوئن ',
          ' ژوئيه ',
          ' اوت ',
          ' سپتامبر ',
          ' اکتبر ',
          ' نوامبر ',
          ' دسامبر '},//this displays funny on a single line
          new String[] //urdu
          {' جنوری ',
            ' فروری ',
            ' مارچ ',
            ' اپریل ',
            ' مئی ',
            ' جون ',
            ' جولائی ',
            ' اگست ',
            ' ستمبر ',
            ' اکتوبر ',
            ' نومبر ',
            ' دسمبر '}
      };
      
      if(language.equals('English'))
      { RetVal = TDate.format('dd') + Tlist.get(0).get(TDate.month() - 1) + TDate.format('yyyy'); }
      else if(language.equals('Spanish'))
      { RetVal = TDate.format('dd') + Tlist.get(1).get(TDate.month() - 1) + TDate.format('yyyy'); }
      else if(language.equals('French'))
      { RetVal = TDate.format('dd') + Tlist.get(2).get(TDate.month() - 1) + TDate.format('yyyy'); }
      else if(language.equals('Portuguese'))
      { RetVal = TDate.format('dd') + Tlist.get(3).get(TDate.month() - 1) + TDate.format('yyyy'); }
      else if(language.equals('Chinese'))
      { RetVal = TDate.format('yyyy.MM.dd'); }
      else if(language.equals('Russian'))
      {
         RetVal = 
            TDate.format('dd') + Tlist.get(5).get(TDate.month() - 1) + TDate.format('yyyy') + ' года';
      }
      else if(language.equals('Arabic'))
      { RetVal = TDate.format('dd') + Tlist.get(6).get(TDate.month() - 1) + TDate.format('yyyy'); }
      else if(language.equals('Persian'))
      { RetVal = TDate.format('dd') + Tlist.get(7).get(TDate.month() - 1) + TDate.format('yyyy'); }
      else if(language.equals('Urdu'))
      { RetVal = TDate.format('dd') + Tlist.get(8).get(TDate.month() - 1) + TDate.format('yyyy'); }
      
      
      return RetVal;
   }
   
   public static string DetermineProclamation(string Language, string Subtype)
   {
      string retVal = '';
      
      if(Language.equals('English'))
      {
         if((Subtype.equals('Discretionary Diplomatic Distribution')) ||
            (Subtype.equals('Embargoed Text')) || (Subtype.equals('Staff Use Only')) ||
            (Subtype.equals('Byliner')) || (Subtype.equals('Fact Sheet')) ||
            (Subtype.equals('Text')) || (Subtype.equals('Transcript')) ||
            (Subtype.equals('Unattributed Staff Written')))
         {
            retVal = '(Distributed by the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)';
         }
         else if((Subtype.equals('Audio')) || (Subtype.equals('Book')) ||
            (Subtype.equals('eJournal')) || (Subtype.equals('IIP Staff Written')) ||
            (Subtype.equals('In Brief')) || (Subtype.equals('Photo Gallery')) ||
            (Subtype.equals('Publication')) || (Subtype.equals('Video')) ||
            (Subtype.equals('Pamphlet')))
         {
            retVal = '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)';
         }
      }
      else if(Language.equals('French'))
      {
         if((Subtype.equals('Audio')) || (Subtype.equals('Book')) ||
            (Subtype.equals('eJournal')) || (Subtype.equals('Fact Sheet')) ||
            (Subtype.equals('In Brief')) || (Subtype.equals('Photo Gallery')) ||
            (Subtype.equals('Text')) || (Subtype.equals('Transcript')) ||
            (Subtype.equals('Video')))
         {
            retVal = '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)';
         }
         else if((Subtype.equals('Byliner')) || (Subtype.equals('IIP Staff Written')) ||
            (Subtype.equals('Unattributed Staff Written')))
         {
            retVal = '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)';
         }
         
      }
      else if(Language.equals('Spanish'))
      {
         retVal = '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)';
      }
      else if(Language.equals('Russian'))
      {
         if((Subtype.equals('Audio')) || (Subtype.equals('IIP Staff Written')) ||
            (Subtype.equals('Photo Gallery')) || (Subtype.equals('Video')) ||
            (Subtype.equals('Unattributed Staff Written')))
         {
            retVal = '(This is a product of the Bureau of International Information Programs, U.S. Department of State. Web site: http://iipdigital.usembassy.gov/iipdigital-en/index.html)';
         }
         else if((Subtype.equals('Book')) || (Subtype.equals('Byliner')) ||
            (Subtype.equals('eJournal')) || (Subtype.equals('Fact Sheet')) ||
            (Subtype.equals('In Brief')) || (Subtype.equals('Text')) ||
            (Subtype.equals('Transcript')))
         {
            retVal = '(Распространено Бюро международных информационных программ Государственного департамента США. Веб-сайт: http://iipdigital.usembassy.gov/iipdigital-ru/index.html )';
         }
      }
      else if(Language.equals('Chinese'))
      {
         retVal = '美国国务院国际信息局 http://iipdigital.usembassy.gov/iipdigital-mgck/index.html';
      }
      else if(Language.equals('Portuguese'))
      {
         if((Subtype.equals('Embargoed Text')) || (Subtype.equals('Byliner')) ||
            (Subtype.equals('Fact Sheet')) || (Subtype.equals('In Brief')) ||
            (Subtype.equals('Text')) || (Subtype.equals('Transript')))
         {
            retVal = '(Distribuído pelo Bureau de Programas de Informações Internacionais do Departamento de Estado dos EUA. Site: http://iipdigital.usembassy.gov/iipdigital-pt/index.html)';
         }
         else if((Subtype.equals('Audio')) || (Subtype.equals('Book')) ||
            (Subtype.equals('eJournal')) || (Subtype.equals('IIP Staff Written')) ||
            (Subtype.equals('Photo Gallery')) || (Subtype.equals('Video')) ||
            (Subtype.equals('Unattributed Staff Written')))
         {
            retVal = '(Produzido pelo Bureau de Programas de Informações Internacionais do Departamento de Estado dos EUA. Site: http://iipdigital.usembassy.gov/iipdigital-pt/index.html)';
         }
      }
      //for arabic and persian these are left blank
      
      return retVal;
   }
   
   public static string ReturnCategory(integer CatNum, string CatField, string Language)
   {
      string retVal = '';
      string tempstr = '';
      
      if(CatField == null)
      {
        return retVal;
      }
      
      if(Language == 'English')
      { retVal = 'EN/'; }
      if(Language == 'Spanish')
      { retVal = 'ES/'; }
      if(Language == 'French')
      { retVal = 'FR/'; }
      if(Language == 'Portuguese')
      { retVal = 'PT/'; }
      if(Language == 'Chinese')
      { retVal = 'ZH/'; }
      if(Language == 'Russian')
      { retVal = 'RU/'; }
      if(Language == 'Arabic')
      { retVal = 'AR/'; }
      if(Language == 'Persian')
      { retVal = 'FA/'; }
      if(Language == 'Urdu')
      { retVal = 'UR/'; }
      if(Language == 'Turkish')
      { retVal = 'TR/'; }
      
      string[] thingy = CatField.split(';', 0);
      
      if(CatNum >= thingy.size())
      {
        retVal = '';
      }
      else
      {
         tempstr = thingy[CatNum].trim();
         
         if(tempstr == 'Africa')
         { retVal += 'REGION/AFRICA'; }
         else if(tempstr == 'East Asia & Pacific')
         { retVal += 'REGION/EAP'; }
         else if(tempstr == 'Europe & Eurasia')
         { retVal += 'REGION/EUR'; }
         else if(tempstr == 'Middle East & North Africa')
         { retVal += 'REGION/MENA'; }
         else if(tempstr == 'South & Central Asia')
         { retVal += 'REGION/SCA'; }
         else if(tempstr == 'Western Hemisphere')
         { retVal += 'REGION/AMERICAS'; }
         else if(tempstr == 'POTUS')
         { retVal += 'NONE/POTUS'; }
         else if(tempstr == 'Secretary of State')
         { retVal += 'NONE/SECSTATE'; }
         else if(tempstr == 'Table of Contents')
         { retVal += 'PUBS/TOC'; }
         else if(tempstr == 'APEC')
         { retVal += 'NONE/APEC'; }
         else if(tempstr == 'Iran')
         { retVal += 'REGION/IRAN'; }
          else if(tempstr == 'Iraq')
         { retVal += 'REGION/IRAQ'; }
         else if(tempstr == 'Brazil')
         { retVal += 'REGION/BRAZIL'; }
         else if(tempstr == 'Burma')
         { retVal += 'REGION/BURMA'; }
         else if(tempstr == 'North Korea')
         { retVal += 'REGION/NORTHKOREA'; }
         else if(tempstr == 'U.S.-China Relations')
         { retVal += 'REGION/USCHINA'; }
         else if(tempstr == 'The Americas')
         { retVal += 'REGION/AMERICAS'; }
         else if(tempstr == 'Central America')
         { retVal += 'REGION/CENTAM'; }
         else if(tempstr == 'Mexico')
         { retVal += 'REGION/MEXICO'; }
         else if(tempstr == 'South America')
         { retVal += 'REGION/AMERICAS'; }
         else if(tempstr == 'Summit of the Americas')
         { retVal += 'NONE/SOTA'; }
         else if(tempstr == '50 States')
         { retVal += 'NONE/50STATES'; }
         else
         { retVal = ''; }
      } 
      
      return retVal;
   }
   
   public static string UpdateBodyURLs(string actualBody)
   {
      string tron = '';
      
      Pattern expression = Pattern.compile('expression');
      Matcher results = expression.matcher('bodystring');
      
      if(results.matches())
      {
        
      }
      
      return actualBody;
   }
   
   public static string UpdateURL(string URL)
   {
      HttpRequest req = new HttpRequest();
      HttpResponse res = new HttpResponse();
      Http http = new Http();
      
      String slugID;
      String[] BodyArray;
      String response;
      integer endlocation;
      integer size;
      
      BodyArray = URL.split('/');
      size = BodyArray.Size();
      
      endlocation = BodyArray[size - 1].indexOf('.html');
      
      if(endlocation != -1)
      {
         slugID = BodyArray[size - 1];
         slugID = slugID.substring(0,endlocation);
      }
      
      //This is the endpoint for the test server
      //req.setEndpoint('http://preprod.iipdigital.getusinfo.com/st/topath/' + slugID);
      
      //This is the endpoint for the real server
      req.setEndpoint('http://iipdigital.usembassy.gov/st/topath/' + slugID);
      
      req.setMethod('GET');
      //req.setHeader('Content-Type','application/x-www-form-urlencoded');
      //req.setBody('xml=' + EncodingUtil.urlEncode(xml, 'UTF-8'));

      //System.debug('http://iipdigital.usembassy.gov/st/topath/' + slugID);

       
      try
      {
         res = http.send(req);
         response = res.getBody();
      }
      catch(System.CalloutException e)
      {
         System.debug('Callout error: '+ e);
         System.debug(res.toString());
         
         return res.toString();
         return 'www.I_HIT_THE_EXCEPTION.com';
      }
      
      if(response == null)
      { return 'www.There_was_a_null_response.com'; }
      
      if(response.contains('404 Not Found'))
      { return URL; }
            
      return 'http://iipdigital.usembassy.gov' + response;

       
       return response;
   }
}