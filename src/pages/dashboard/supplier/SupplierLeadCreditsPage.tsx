import { Navigate } from 'react-router-dom';

/**
 * Lead Credits purchase flow removed from manufacturer dashboard.
 * Old /lead-credits, /credits, /wallet URLs redirect to Subscription.
 */
export default function SupplierLeadCreditsPage() {
  return <Navigate to="/dashboard/supplier/subscription" replace />;
}
