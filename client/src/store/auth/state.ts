export interface AuthInterface {
  isAuthenticating: boolean;
  isAuthenticated: boolean;
  playerId: string;
  synced: boolean;
}

const state: AuthInterface = {
  isAuthenticating: false,
  isAuthenticated: false,
  playerId: '',
  synced: false
};

export default state;
