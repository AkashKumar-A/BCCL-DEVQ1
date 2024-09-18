@isTest
global class MockResponseGeneratorForNewsRSSAccount implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        string documentString = '<rss xmlns:valurl="com.times.utilities.CMSWebUtility" xmlns:atom="http://www.w3.org/2005/Atom" version="2.0"> <channel> <title>Industry-Economic Times</title> <link>https://economictimes.indiatimes.com/industry</link> <description> Offers Latest Industry News Analysis, Industries News Updates and Government Policy on Industries. </description> <language>en-gb</language> <lastBuildDate>2018-12-13T15:53:31+05:30</lastBuildDate> <atom:link type="application/rss+xml" rel="self" href="https://economictimes.indiatimes.com/rssfeeds/13352306.cms"/> <docs>http://syndication.indiatimes.com/</docs> <image> <title>Economic Times</title> <url>https://img.etimg.com/photo/39814569.cms</url> <link>https://economictimes.indiatimes.com/industry</link> </image> <item> <title> Hindustan is part & parcel of government which hasnt destroyed it: Nitin Gadkari </title> <description> <a href="https://economictimes.indiatimes.com/industry/rbi-is-part-parcel-of-government-which-hasnt-destroyed-it-nitin-gadkari/articleshow/67075540.cms"><img width="100" height="75" border="0" hspace="10" align="left" src="https://img.etimg.com/photo/67075540.cms"/></a>Gadkari asserted that the central bank continues to be by and large an independent body but it should also support the economic vision of the government of the day. </description> <link> https://economictimes.indiatimes.com/industry/banking/finance/banking/rbi-is-part-parcel-of-government-which-hasnt-destroyed-it-nitin-gadkari/articleshow/67075540.cms </link> <image> https://img.etimg.com/thumb/width-310,resizemode-4,msid-67075540/rbi-is-part-parcel-of-government-which-hasnt-destroyed-it-nitin-gadkari.jpg </image> <guid> Article at EconomicTimes.com with article id : 67075540 </guid> <pubDate>2018-12-13T15:52:22+05:30</pubDate> </item> </channel> </rss>';
        documentString = documentString.replace('&','&amp;');
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody(documentString);
        res.setStatusCode(200);
        return res;
    }
}