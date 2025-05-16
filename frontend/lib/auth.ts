import axios, { AxiosInstance } from 'axios';
import { ApiResponse, TokenResponse, UserMe } from '../types/auth';

const API: AxiosInstance = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_BASE,
  withCredentials: true,
});

// Sign up: server will set HttpOnly cookie
export async function signup(
  username: string, email: string, password: string
): Promise<TokenResponse> {
  const res = await API.post<ApiResponse<TokenResponse>>(
    '/auth/signup', { username, email, password }
  );
  return res.data.data;
}

// Login: server sets cookie
export async function login(
  username: string, password: string
): Promise<TokenResponse> {
  const res = await API.post<ApiResponse<TokenResponse>>(
    '/auth/login', { username, password }
  );
  return res.data.data;
}

// Get current user
export async function me(): Promise<UserMe> {
  const res = await API.get<ApiResponse<UserMe>>('/auth/me');
  return res.data.data;
}

export async function logout(): Promise<void> {
  await API.post('/auth/logout');
}
