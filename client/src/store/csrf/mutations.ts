import { MutationTree } from 'vuex';
import { CsrfInterface } from './state';

const mutation: MutationTree<CsrfInterface> = {
  setCsrfToken(state: CsrfInterface, token: string) {
    state.token = token;
  }
};

export default mutation;
