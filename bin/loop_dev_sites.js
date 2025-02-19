import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    vus: 1,           // Number of virtual users
    duration: '20s',  // Duration of the test
};

const urls = [ 
    'https://acorn-dev.lib.harvard.edu/records/list',
    'https://arclight-dev.lib.harvard.edu/',
    'https://aspace-dev.lib.harvard.edu',
    'https://aspaceapi-dev.lib.harvard.edu',
    'https://aspacepui-dev.lib.harvard.edu',
    'https://bibdata-dev.lib.harvard.edu',
    'https://booklabeler-dev.lib.harvard.edu',
    'https://collex-dev.lib.harvard.edu',
    'https://curiosity-dev.lib.harvard.edu',
    'https://dims-dev.lib.harvard.edu/readiness',
    'https://drs2-services-dev.hul.harvard.edu/',
    'https://drs2-dev.hul.harvard.edu',
    'https://drs2-dev.hul.harvard.edu/drs2_webadmin/search',
    'https://eadchecker-dev.lib.harvard.edu',
    'https://eda-dev.lib.harvard.edu',
    'https://embed-dev.lib.harvard.edu',
    'https://fts-dev.lib.harvard.edu',
    'https://hgl-dev.lib.harvard.edu',
    'https://ids-dev.lib.harvard.edu/ids/view/400013131',
    'https://iiif-dev.lib.harvard.edu',         //IDS
    'https://jstor-dev.lib.harvard.edu', 
    'https://jobmon-dev.lib.harvard.edu',
    'https://lc-tools-dev.lib.harvard.edu/oai/?verb=ListSets',
    'https://lc-tools-dev.lib.harvard.edu/csv/',
    'https://listview-dev.lib.harvard.edu',
    'https://mps-dev.lib.harvard.edu/',
    'https://pds-dev.lib.harvard.edu',          //IDS
    'https://tools-dev.lib.harvard.edu',  
    'https://cluster-console.dev.lib.harvard.edu',
    'https://deployment.dev.lib.harvard.edu',
    // 'https://another-site.com',
];

export default function () {
    for (let url of urls) {
        let response = http.get(url);
        console.log(`Response time for ${url}: ${response.timings.duration} ms`);
        sleep(1);  // Wait for 1 second between requests
    }
}
