import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    vus: 1,           // Number of virtual users
    duration: '10s',  // Duration of the test
};

const urls = [ 
    'https://acorn-qa.lib.harvard.edu/records/list',
    'https://arclight-qa.lib.harvard.edu/',
    'https://aspace-qa.lib.harvard.edu',
    'https://bibdata-qa.lib.harvard.edu',
    'https://booklabeler-dev.lib.harvard.edu',
    'https://curiosity-qa.lib.harvard.edu',
    'https://dims-qa.lib.harvard.edu',
    'https://eda-qa.lib.harvard.edu',
    'https://embed-qa.lib.harvard.edu',
    'https://fts-qa.lib.harvard.edu',
    'https://geodata-qa.lib.harvard.edu',
    'https://jstor-qa.lib.harvard.edu',
    'https://hgl-qa.lib.harvard.edu',
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
