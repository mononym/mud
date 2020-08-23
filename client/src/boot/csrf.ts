// import something here
import axios, { AxiosResponse } from 'axios';
import { boot } from 'quasar/wrappers'

// "async" is optional;
// more info on params: https://quasar.dev/quasar-cli/cli-documentation/boot-files#Anatomy-of-a-boot-file
export default boot(async () => {
  console.log('session')
  // something to do
  await axios
    .post('/csrf-token')
    .then(function(response: AxiosResponse) {
      axios.defaults.headers.post['x-csrf-token'] = response.data;
    })
});
