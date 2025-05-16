import { Profile } from '../lib/profile';

export default function ProfileList({ profiles }: { profiles: Profile[] }) {
  return (
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
      </tbody>
    </table>
  );
}
