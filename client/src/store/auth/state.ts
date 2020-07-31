export interface AuthInterface {
  isAuthenticating: boolean;
  isAuthenticated: boolean;
  playerId: string;
}

const state: AuthInterface = {
  isAuthenticating: false,
  isAuthenticated: false,
  playerId: ''
};

export default state;
