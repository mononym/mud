import Api from "../services/api";
import type {AxiosResponse} from 'axios'
import type { PlayerInterface } from "../models/player";

// Method to begin login/signup process by submitting an email address
// export const submitEmailForAuth = async (email) => {
//     try {
//       const response = await Api.post("/authenticate/email", {email: email});
//       return response.data;
//     } catch (error) {
//       console.error(error);
//     }
// };
export async function submitEmailForAuth(email: string): Promise<AxiosResponse<unknown>> {
  return await Api.post("/authenticate/email", {email: email});
}

// Method for finalizing login/signup via OTP token
// export const submitTokenForAuth = async (token) => {
//   try {
//     const response = await Api.post("/authenticate/token", {token: token});
//     return response.data;
//   } catch (error) {
//     console.error(error);
//   }
// };
export async function submitTokenForAuth(token: string): Promise<AxiosResponse<PlayerInterface>> {
  return await <Promise<AxiosResponse<PlayerInterface>>>Api.post("/authenticate/token", {token: token});
}

export async function syncPlayer(): Promise<AxiosResponse<{authenticated: boolean, player: PlayerInterface}>> {
  return await <Promise<AxiosResponse<{authenticated: boolean, player: PlayerInterface}>>>Api.get("/authenticate/sync");
}