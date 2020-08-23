export interface AuthInterface {
  isAuthenticating: boolean;
  isAuthenticated: boolean;
  playerId: string;
  isSynced: boolean;
}

const state: AuthInterface = {
  isAuthenticating: false,
  isAuthenticated: false,
  playerId: '',
  isSynced: false
};

export default state;
