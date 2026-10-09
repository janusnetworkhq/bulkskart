import React from 'react';
import Header from './Header';
import Footer from './Footer';
interface MainLayoutProps {
  children: React.ReactNode;
  hideFooter?: boolean;
}

export default function MainLayout({ children, hideFooter = false }: MainLayoutProps) {
  return (
    <div className="flex flex-col min-h-screen w-full max-w-[100vw] overflow-x-hidden bg-background">
      <Header />
      <main className="flex-1 min-w-0 w-full max-w-[100vw] overflow-x-hidden pb-12 sm:pb-16 md:pb-20">
        {children}
      </main>
      {!hideFooter && <Footer />}
    </div>
  );
}
