import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    vus: 1,           // Number of virtual users
    duration: '60s',  // Duration of the test
};

const urls = [ 
    'https://acorn-qa.lib.harvard.edu/records/list',
    'https://arclight-qa.lib.harvard.edu/',
    'https://api-qa.lib.harvard.edu/v2/items',                      //LibraryCloud
    'https://aspace-qa.lib.harvard.edu',
    'https://aspaceapi-qa.lib.harvard.edu',
    'https://aspacepui-qa.lib.harvard.edu/',
    'https://bibdata-qa.lib.harvard.edu',
    'https://booklabeler-qa.lib.harvard.edu',
    'https://curiosity-qa.lib.harvard.edu',
    'https://dims-qa.lib.harvard.edu/readiness',
    'https://eda-qa.lib.harvard.edu',   
    'https://embed-qa.lib.harvard.edu',                            //Viewer
    'https://fts-qa.lib.harvard.edu',
    'https://geodata-qa.lib.harvard.edu',
    'https://hgl-qa.lib.harvard.edu',
    'https://ids-qa.lib.harvard.edu/ids/view/401656372',
    'https://jobmon-qa.lib.harvard.edu',
    'https://jstor-qa.lib.harvard.edu',
    'https://lc-tools-qa.lib.harvard.edu/oai/?verb=ListSets',       //LibraryCloud
    'https://lc-tools-qa.lib.harvard.edu/csv/',                    //LibraryCloud  
    'https://listview-qa.lib.harvard.edu',
    'https://lts-pipelines-qa.lib.harvard.edu/login',
    'https://mps-qa.lib.harvard.edu/assets/images/DRS:401074141/full/1200,1200/0/default.jpg', 
    'https://mps-qa.lib.harvard.edu/assets/image/DRS:400483064',
    'https://mps-qa.lib.harvard.edu/sds/audio/401065821',
    'https://mps-qa.lib.harvard.edu/sds/audio/402349903',           //SDS Audio
    'https://mps-qa.lib.harvard.edu/sds/video/402164813',           //SDS Video
    'https://nrsadmin-qa.lib.harvard.edu/resources/search/advanced',
    'https://nrsadmin-api-qa.lib.harvard.edu',
    'https://nrs-qa.lib.harvard.edu/URN-3:HUL.OIS:726231:MANIFEST:3',
    'https://nrs-qa.lib.harvard.edu/URN-3:HUL.OIS:726231:MANIFEST:2',
    'https://olivia-qa.lib.harvard.edu/olivia/servlet/OliviaServlet',
    'https://pds-qa.lib.harvard.edu/pds/',
    'https://policyadmin-qa.lib.harvard.edu/policy/servlet/admin',
    'https://viewer-qa.lib.harvard.edu',                           //Viewer
    'https://webservices-qa.lib.harvard.edu/rest/v3/hollis/barcode/32044051654705',     //Presto
    'https://cluster-console.qa.lib.harvard.edu',
    'https://deployment.qa.lib.harvard.edu',
    'https://logs.qa.lib.harvard.edu/login'
    // 'https://another-site.com',
];

export default function () {
    for (let url of urls) {
        let response = http.get(url);
        console.log(`Response time for ${url}: ${response.timings.duration} ms`);
        sleep(1);  // Wait for 1 second between requests
    }
}
