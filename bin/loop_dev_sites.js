import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    vus: 1,           // Number of virtual users
    duration: '10s',  // Duration of the test
};

const urls = [ 
    'https://acorn-dev.lib.harvard.edu/records/list',
    'https://arclight-dev.lib.harvard.edu/',
    'https://aspace-dev.lib.harvard.edu',
    'https://bibdata-dev.lib.harvard.edu',
    'https://booklabeler-dev.lib.harvard.edu',
    'https://curiosity-dev.lib.harvard.edu',
    'https://cluster-console.dev.lib.harvard.edu',
    // 'https://another-site.com',
];

export default function () {
    for (let url of urls) {
        let response = http.get(url);
        console.log(`Response time for ${url}: ${response.timings.duration} ms`);
        sleep(1);  // Wait for 1 second between requests
    }
}
