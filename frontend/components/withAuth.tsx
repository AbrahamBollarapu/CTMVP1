import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import { me } from '../lib/auth';
import Spinner from './Spinner';

export function withAuth<P>(Wrapped: React.ComponentType<P>) {
  return (props: P) => {
    const [loading, setLoading] = useState(true);
    const router = useRouter();

    useEffect(() => {
      (async () => {
        try {
          await me();
        } catch (err) {
          console.error('Auth check failed', err);
          router.replace('/login');
          return;
        }
        setLoading(false);
      })();
    }, [router]);

    if (loading) return <Spinner />;
    return <Wrapped {...props} />;
  };
}
