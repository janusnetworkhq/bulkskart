/**
 * Full-page skeleton shown while a lazy-loaded route chunk is fetching.
 * Matches the app's header height so the layout doesn't shift.
 */
export default function PageSkeleton() {
  return (
    <div className="flex flex-col min-h-screen bg-background animate-pulse">
      {/* Simulated header bar */}
      <div className="h-14 bg-card border-b border-border shrink-0" />

      {/* Page body */}
      <div className="flex-1 max-w-[1400px] w-full mx-auto px-4 md:px-6 py-8 space-y-6">
        {/* Hero / banner area */}
        <div className="w-full h-48 md:h-64 rounded-2xl bg-muted" />

        {/* Two-column content skeleton */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="md:col-span-2 space-y-3">
            <div className="h-5 w-2/3 rounded bg-muted" />
            <div className="h-4 w-full rounded bg-muted" />
            <div className="h-4 w-5/6 rounded bg-muted" />
            <div className="h-4 w-4/6 rounded bg-muted" />
          </div>
          <div className="space-y-3">
            <div className="h-32 rounded-xl bg-muted" />
            <div className="h-4 w-3/4 rounded bg-muted" />
            <div className="h-4 w-2/3 rounded bg-muted" />
          </div>
        </div>

        {/* Card grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="rounded-xl bg-muted h-36" />
          ))}
        </div>
      </div>
    </div>
  );
}
