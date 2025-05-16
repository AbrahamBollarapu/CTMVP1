import axios from "axios";

export interface Profile {
  id: number;
  user_id: number;
  role: string;
  carbon_score: number;
}

const API = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_BASE,
  withCredentials: true
});

export async function getProfiles(role?: string): Promise<Profile[]> {
  const resp = await API.get<Profile[]>(`/profile${role ? `?role=${role}` : ""}`);
  return resp.data;
}

export async function upsertProfile(p: Profile): Promise<Profile> {
  const resp = await API.post<Profile>("/profile/", p);
  return resp.data;
}
