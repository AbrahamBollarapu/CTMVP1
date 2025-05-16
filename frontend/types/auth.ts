export interface ApiResponse<T> {
  data: T;
}

export interface TokenResponse {
  access_token: string;
  token_type: 'bearer';
}

export interface UserMe {
  id: number;
  username: string;
  email: string;
}
