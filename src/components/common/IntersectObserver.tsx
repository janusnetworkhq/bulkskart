import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { Observer } from 'tailwindcss-intersect';

const IntersectObserver = () => {
  const location = useLocation();

  useEffect(() => {
    // When the location changes, restart observer with safe guard
    const timer = setTimeout(() => {
      try {
        if (typeof window !== 'undefined' && 'IntersectionObserver' in window) {
          Observer.restart();
        }
      } catch {
        // Silently skip if intersection observer is not available on older client device
      }
    }, 100);

    return () => clearTimeout(timer);
  }, [location]);

  return null;
};

export default IntersectObserver;
