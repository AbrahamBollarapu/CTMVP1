import { useEffect, useState, FormEvent } from 'react'
import { getProfiles, upsertProfile } from '../../lib/profile'

interface Profile {
  id: number
  user_id: number
  role: string
  carbon_score: number
}

interface NewProfile {
  user_id: string
  role: string
  carbon_score: string
}

export default function UserProfilePage() {
  const [profiles, setProfiles] = useState<Profile[]>([])
  const [newProfile, setNewProfile] = useState<NewProfile>({
    user_id: '',
    role: '',
    carbon_score: ''
  })
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    load()
  }, [])

  const load = async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await getProfiles()
      setProfiles(data)
    } catch (err) {
      setError('Failed to load profiles')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    try {
      await upsertProfile({
        user_id: Number(newProfile.user_id),
        role: newProfile.role,
        carbon_score: Number(newProfile.carbon_score)
      })
      setNewProfile({ user_id: '', role: '', carbon_score: '' })
      load()
    } catch (err) {
      setError('Failed to add or update profile')
      console.error(err)
    }
  }

  return (
    <div>
      <h1>User Profiles</h1>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <form onSubmit={handleSubmit} style={{ marginBottom: '1rem' }}>
        <label>
          User ID:
          <input
            type="number"
            placeholder="User ID"
            value={newProfile.user_id}
            onChange={e => setNewProfile({ ...newProfile, user_id: e.target.value })}
            required
          />
        </label>
        <label>
          Role:
          <input
            type="text"
            placeholder="Role"
            value={newProfile.role}
            onChange={e => setNewProfile({ ...newProfile, role: e.target.value })}
            required
          />
        </label>
        <label>
          Carbon Score:
          <input
            type="number"
            placeholder="Carbon Score"
            value={newProfile.carbon_score}
            onChange={e => setNewProfile({ ...newProfile, carbon_score: e.target.value })}
            required
          />
        </label>
        <button type="submit">Add</button>
      </form>

      {loading ? (
        <p>Loading...</p>
      ) : (
        <table>
          <caption>User Profiles List</caption>
          <thead>
            <tr>
              <th>User</th>
              <th>Role</th>
              <th>Score</th>
            </tr>
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
      )}
    </div>
  )
}