import axios, { AxiosInstance } from 'axios';
import { boot } from 'quasar/wrappers';

declare module 'vue/types/vue' {
  interface Vue {
    $axios: AxiosInstance;
  }
}

axios.defaults.baseURL = 'http://localhost:4000';
axios.defaults.withCredentials = true;

axios.interceptors.response.use(
  response => {
    console.log(response);
    return response;
  },
  error => {
    if (error.response.status === 401) {
      alert('You are not authorized');
    }

    if (error.response && error.response.data) {
      return Promise.reject(error.response.data);
    }
    return Promise.reject(error.message);
  }
);

export default boot(({ Vue }) => {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
  Vue.prototype.$axios = axios;
});
