# scaffold-ui.ps1
# Run this from: D:\CTMVP1\frontend

# 1. Ensure directories exist
@(
  "styles",
  "pages",
  "pages\dashboard"
) | ForEach-Object {
  if (!(Test-Path $_)) {
    New-Item -ItemType Directory -Path $_ | Out-Null
    Write-Host "✅ Created directory: $_"
  }
}

# 2. styles/globals.css
@"
body {
  font-family: sans-serif;
  margin: 2rem;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}

th, td {
  padding: 0.5rem;
  border: 1px solid #ddd;
  text-align: left;
}

th {
  background: #f5f5f5;
}
"@ | Set-Content -Path "styles/globals.css" -Encoding utf8
Write-Host "✅ Created/updated: styles/globals.css"

# 3. pages/_app.tsx
@"
import '../styles/globals.css'
import type { AppProps } from 'next/app'

export default function MyApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />
}
"@ | Set-Content -Path "pages/_app.tsx" -Encoding utf8
Write-Host "✅ Created/updated: pages/_app.tsx"

# 4. pages/dashboard/user-profile.tsx
@"
import { useEffect, useState, FormEvent } from 'react'
import { getProfiles, upsertProfile } from '../../lib/profile'

interface Profile {
  id: number
  user_id: number
  role: string
  carbon_score: number
}

export default function UserProfilePage() {
  const [profiles, setProfiles] = useState<Profile[]>([])
  const [newProfile, setNewProfile] = useState({
    user_id: '',
    role: '',
    carbon_score: ''
  })

  useEffect(() => {
    load()
  }, [])

  const load = async () => {
    const data = await getProfiles()
    setProfiles(data)
  }

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    await upsertProfile({
      user_id: Number(newProfile.user_id),
      role: newProfile.role,
      carbon_score: Number(newProfile.carbon_score)
    })
    setNewProfile({ user_id: '', role: '', carbon_score: '' })
    load()
  }

  return (
    <div>
      <h1>User Profiles</h1>
      <form onSubmit={handleSubmit} style={{ marginBottom: '1rem' }}>
        <input
          placeholder=\"User ID\"
          value={newProfile.user_id}
          onChange={e => setNewProfile({ ...newProfile, user_id: e.target.value })}
          required
        />
        <input
          placeholder=\"Role\"
          value={newProfile.role}
          onChange={e => setNewProfile({ ...newProfile, role: e.target.value })}
          required
        />
        <input
          placeholder=\"Carbon Score\"
          value={newProfile.carbon_score}
          onChange={e => setNewProfile({ ...newProfile, carbon_score: e.target.value })}
          required
        />
        <button type=\"submit\">Add</button>
      </form>

      <table>
        <thead>
          <tr><th>User</th><th>Role</th><th>Score</th></tr>
        </thead>
        <tbody>
          {profiles.map(p => (
            <tr key={p.id}>
              <td>{p.user_id}</td>
              <td>{p.role}</td>
              <td>{p.carbon_score}</td>
            </tr>
          ))}
          {profiles.length === 0 && (
            <tr>
              <td colSpan={3} style={{ textAlign: 'center' }}>
                No profiles found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
)
}
"@ | Set-Content -Path "pages/dashboard/user-profile.tsx" -Encoding utf8
Write-Host "✅ Created/updated: pages/dashboard/user-profile.tsx"
