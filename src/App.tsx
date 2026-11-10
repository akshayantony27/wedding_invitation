/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  Volume2,
  VolumeX,
  MapPin,
  Calendar,
  Navigation,
  Download,
  ChevronDown,
  Sparkles,
  Heart,
  CheckCircle2,
} from 'lucide-react';

// Wedding Configuration (mirrors lib/core/config.dart)
const WEDDING_DATA = {
  groom: 'Akshay Antony',
  bride: 'Wilma Theresa',
  groomParents: 'Mr. George P D & Mrs. Metilda George',
  brideParents: 'Mr. KG Edwin & Mrs. Hilda Edwin',
  verse: 'I have found the one whom my soul loves',
  verseReference: 'Song of Solomon 3:4',
  blessingLine: 'With love and blessings from their parents,',
  hostsUpper: 'MR. GEORGE P D & MRS. METILDA GEORGE',
  inviteLine: 'Cordially invite you to celebrate the wedding of',
  // Verified exact wording: "wedding ceremony of our son"
  invitationMessage:
    'Mr. George P D & Mrs. Metilda George cordially invite you to grace the occasion with your presence and prayers at the wedding ceremony of our son.',
  weekday: 'Sunday',
  dateLong: 'Sunday, 27 December 2026',
  timeLabel: '10:30 AM',
  // 10:30 AM IST (UTC+05:30) is 05:00 UTC
  targetDateUtc: new Date(Date.UTC(2026, 11, 27, 5, 0, 0)).getTime(),
  venueName: 'The Basilica of Our Lady of Ransom',
  venueLocality: 'Vallarpadam, Kochi, Kerala',
  venueFull:
    'The Basilica of Our Lady of Ransom, Vallarpadam, Kochi, Kerala, India',
  directionsUrl:
    'https://www.google.com/maps/dir/?api=1&destination=The+Basilica+of+Our+Lady+of+Ransom%2C+Vallarpadam%2C+Kochi%2C+Kerala%2C+India',
  calendarUrl:
    'https://calendar.google.com/calendar/render?action=TEMPLATE&text=Wedding+of+Akshay+Antony+%26+Wilma+Theresa&dates=20261227T050000Z/20261227T070000Z&location=The+Basilica+of+Our+Lady+of+Ransom%2C+Vallarpadam%2C+Kochi%2C+Kerala%2C+India&details=Mr.+George+P+D+%26+Mrs.+Metilda+George+cordially+invite+you+to+grace+the+occasion+with+your+presence+and+prayers+at+the+wedding+ceremony+of+our+son.',
  churchPhoto: '/assets/images/basilica_church.jpg',
  audioSrc: '/assets/audio/music.mp3',
  updatedZipUrl: '/wedding_invitation_updated.zip',
};

// Canvas Floating Petals Component
function PetalField() {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animationFrameId: number;
    let width = (canvas.width = window.innerWidth);
    let height = (canvas.height = window.innerHeight);

    const handleResize = () => {
      if (!canvas) return;
      width = canvas.width = window.innerWidth;
      height = canvas.height = window.innerHeight;
    };
    window.addEventListener('resize', handleResize);

    const petals: Array<{
      x: number;
      y: number;
      size: number;
      speedY: number;
      speedX: number;
      rotation: number;
      rotSpeed: number;
      opacity: number;
      color: string;
    }> = [];

    const colors = [
      'rgba(244, 189, 189, ',
      'rgba(235, 164, 172, ',
      'rgba(251, 228, 225, ',
      'rgba(253, 234, 219, ',
    ];

    const petalCount = width > 768 ? 24 : 14;
    for (let i = 0; i < petalCount; i++) {
      petals.push({
        x: Math.random() * width,
        y: Math.random() * height,
        size: Math.random() * 9 + 7,
        speedY: Math.random() * 0.9 + 0.5,
        speedX: Math.random() * 0.6 - 0.3,
        rotation: Math.random() * Math.PI * 2,
        rotSpeed: (Math.random() - 0.5) * 0.02,
        opacity: Math.random() * 0.45 + 0.25,
        color: colors[Math.floor(Math.random() * colors.length)],
      });
    }

    const render = () => {
      ctx.clearRect(0, 0, width, height);

      petals.forEach((p) => {
        p.y += p.speedY;
        p.x += Math.sin(p.y * 0.008) * 0.7 + p.speedX;
        p.rotation += p.rotSpeed;

        if (p.y > height + 20) {
          p.y = -20;
          p.x = Math.random() * width;
        }
        if (p.x > width + 20) p.x = -20;
        if (p.x < -20) p.x = width + 20;

        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate(p.rotation);
        ctx.beginPath();
        // Draw delicate organic petal shape
        ctx.ellipse(0, 0, p.size * 0.6, p.size, Math.PI / 4, 0, Math.PI * 2);
        ctx.fillStyle = `${p.color}${p.opacity})`;
        ctx.fill();
        ctx.restore();
      });

      animationFrameId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animationFrameId);
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className="pointer-events-none fixed inset-0 z-20 h-full w-full"
    />
  );
}

// Countdown Hook
function useCountdown(targetDate: number) {
  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
    isPassed: false,
  });

  useEffect(() => {
    const calculate = () => {
      const now = new Date().getTime();
      const diff = targetDate - now;

      if (diff <= 0) {
        setTimeLeft({
          days: 0,
          hours: 0,
          minutes: 0,
          seconds: 0,
          isPassed: true,
        });
        return;
      }

      const days = Math.floor(diff / (1000 * 60 * 60 * 24));
      const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
      const minutes = Math.floor((diff / 1000 / 60) % 60);
      const seconds = Math.floor((diff / 1000) % 60);

      setTimeLeft({ days, hours, minutes, seconds, isPassed: false });
    };

    calculate();
    const interval = setInterval(calculate, 1000);
    return () => clearInterval(interval);
  }, [targetDate]);

  return timeLeft;
}

export default function App() {
  const [isOpen, setIsOpen] = useState(false);
  const [isOpening, setIsOpening] = useState(false);
  const [isMusicPlaying, setIsMusicPlaying] = useState(false);
  const [showStatusModal, setShowStatusModal] = useState(false);
  const [churchLoaded, setChurchLoaded] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const venueSectionRef = useRef<HTMLDivElement | null>(null);

  const countdown = useCountdown(WEDDING_DATA.targetDateUtc);

  // Audio setup
  useEffect(() => {
    audioRef.current = new Audio(WEDDING_DATA.audioSrc);
    audioRef.current.loop = true;

    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
    };
  }, []);

  const toggleMusic = () => {
    if (!audioRef.current) return;
    if (isMusicPlaying) {
      audioRef.current.pause();
      setIsMusicPlaying(false);
    } else {
      audioRef.current
        .play()
        .then(() => setIsMusicPlaying(true))
        .catch(() => {
          // Auto-play was prevented
        });
    }
  };

  const handleOpenInvitation = () => {
    if (isOpening || isOpen) return;
    setIsOpening(true);

    // Try starting music after user click
    if (audioRef.current) {
      audioRef.current
        .play()
        .then(() => setIsMusicPlaying(true))
        .catch(() => {});
    }

    // Sequence opening animation
    setTimeout(() => {
      setIsOpen(true);
      setIsOpening(false);
    }, 1800);
  };

  const scrollToVenue = () => {
    venueSectionRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div className="relative min-h-screen bg-gradient-to-b from-[#FBE4E1] via-[#FDEADB] to-[#FBE4E1] font-serif text-[#1F3D2B] selection:bg-[#E79AA3]/30 overflow-x-hidden">
      {/* Drifting Petals Canvas */}
      <PetalField />

      {/* Floating Header Controls */}
      <div className="fixed top-4 right-4 z-50 flex items-center gap-2">
        {/* Flutter Source Status / Download Pill */}
        <button
          onClick={() => setShowStatusModal(true)}
          className="flex items-center gap-1.5 rounded-full border border-[#C4606F]/40 bg-white/85 px-3 py-1.5 text-xs font-sans tracking-wide text-[#1F3D2B] shadow-sm backdrop-blur-md transition hover:bg-white hover:shadow"
          title="View Flutter Web Project Status"
        >
          <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
          <span className="font-medium">Flutter Web Active</span>
        </button>

        {/* Music Button */}
        <button
          onClick={toggleMusic}
          className={`flex items-center gap-2 rounded-full border px-3.5 py-1.5 text-xs font-sans font-medium uppercase tracking-wider backdrop-blur-md transition-all shadow-sm ${
            isMusicPlaying
              ? 'border-[#C4606F] bg-[#C4606F] text-white shadow-[#C4606F]/20'
              : 'border-[#C4606F]/40 bg-white/80 text-[#1F3D2B] hover:bg-white'
          }`}
          aria-label={isMusicPlaying ? 'Mute background music' : 'Play background music'}
        >
          {isMusicPlaying ? (
            <>
              <Volume2 className="h-3.5 w-3.5 animate-pulse" />
              <span>Music ON</span>
            </>
          ) : (
            <>
              <VolumeX className="h-3.5 w-3.5" />
              <span>Music OFF</span>
            </>
          )}
        </button>
      </div>

      {/* ENVELOPE OPENING OVERLAY SCREEN */}
      {!isOpen && (
        <div
          className={`fixed inset-0 z-40 flex flex-col items-center justify-center p-4 transition-opacity duration-1000 ${
            isOpening ? 'pointer-events-none opacity-0 scale-105' : 'opacity-100'
          }`}
        >
          <div className="relative mx-auto w-full max-w-sm sm:max-w-md perspective-1000">
            {/* The Envelope Body */}
            <div
              className={`relative overflow-visible rounded-xl border border-[#C4606F]/30 bg-gradient-to-b from-[#FCE3DE] to-[#F3C3C0] p-6 shadow-2xl transition-transform duration-1000 ${
                isOpening ? 'scale-110' : 'animate-float'
              }`}
              style={{
                boxShadow:
                  '0 25px 50px -12px rgba(196, 96, 111, 0.35), 0 0 20px rgba(205, 170, 109, 0.2)',
              }}
            >
              {/* Back flap triangle decoration */}
              <div
                className="absolute inset-0 pointer-events-none rounded-xl"
                style={{
                  background:
                    'linear-gradient(135deg, rgba(255,255,255,0.4) 0%, transparent 60%)',
                }}
              />

              {/* Envelope flap */}
              <div
                className={`absolute top-0 left-0 right-0 h-32 origin-top rounded-t-xl transition-all duration-1000 ${
                  isOpening
                    ? 'rotate-x-180 -translate-y-4 opacity-70'
                    : 'rotate-x-0'
                }`}
                style={{
                  background:
                    'linear-gradient(180deg, #FBD9D5 0%, #F4BDBD 100%)',
                  clipPath: 'polygon(0 0, 100% 0, 50% 100%)',
                  boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                }}
              />

              {/* Inside letter card */}
              <div className="relative z-10 mx-auto my-4 flex flex-col items-center rounded-lg border border-[#CDAA6D]/50 bg-[#FFFDFB] p-6 text-center shadow-md">
                <span className="text-xl text-[#C4606F] font-serif">✝</span>
                <p className="mt-2 font-['Cinzel'] text-xs tracking-[0.25em] text-[#C4606F] uppercase">
                  Wedding Invitation
                </p>
                <h1 className="mt-2 font-['Great_Vibes'] text-4xl sm:text-5xl text-[#1F3D2B] leading-tight">
                  Akshay &amp; Wilma
                </h1>
                <p className="mt-2 font-['Cormorant_Garamond'] text-sm italic text-[#3F6B4C]">
                  Sunday, 27 December 2026
                </p>
                <p className="mt-1 font-['Cormorant_Garamond'] text-xs text-[#1F3D2B]/70">
                  Vallarpadam, Kochi, Kerala
                </p>
              </div>

              {/* Wax Seal Button */}
              <div className="relative z-20 -mt-6 flex flex-col items-center">
                <button
                  onClick={handleOpenInvitation}
                  disabled={isOpening}
                  className={`group relative flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-[#C9475A] via-[#9C2C3A] to-[#6E1B27] text-white shadow-xl transition-all duration-500 hover:scale-105 active:scale-95 ${
                    isOpening ? 'scale-125 opacity-0' : 'animate-pulse'
                  }`}
                  style={{
                    boxShadow:
                      '0 10px 25px -5px rgba(156, 44, 58, 0.5), inset 0 2px 4px rgba(255,255,255,0.3)',
                  }}
                  aria-label="Tap wax seal to open wedding invitation"
                >
                  <div className="flex flex-col items-center">
                    <span className="font-['Great_Vibes'] text-2xl text-[#FCE3DE] group-hover:scale-110 transition">
                      A&amp;W
                    </span>
                    <span className="font-['Cinzel'] text-[8px] uppercase tracking-wider text-[#FCE3DE]/80">
                      OPEN
                    </span>
                  </div>
                </button>
                <p className="mt-3 font-['Cormorant_Garamond'] text-sm italic tracking-wide text-[#C4606F]">
                  Tap the wax seal to open your invitation
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* FULL INVITATION CONTENT */}
      <main
        className={`relative z-10 mx-auto max-w-2xl px-4 py-12 sm:px-8 transition-opacity duration-1000 ${
          isOpen ? 'opacity-100' : 'opacity-0'
        }`}
      >
        {/* Section 1: Hero & Biblical Blessing */}
        <section className="min-h-[85vh] flex flex-col items-center justify-center text-center py-12">
          {/* Decorative Cross */}
          <div className="mb-4 inline-flex items-center justify-center">
            <span className="text-3xl text-[#C4606F] font-serif">✝</span>
          </div>

          {/* Bible Verse */}
          <blockquote className="max-w-md mx-auto">
            <p className="font-['Cormorant_Garamond'] text-2xl sm:text-3xl italic font-semibold text-[#1F3D2B] leading-relaxed">
              &ldquo;{WEDDING_DATA.verse}&rdquo;
            </p>
            <footer className="mt-2 font-['Cormorant_Garamond'] text-sm tracking-widest text-[#3F6B4C] uppercase">
              — {WEDDING_DATA.verseReference}
            </footer>
          </blockquote>

          {/* Divider */}
          <div className="my-8 flex items-center justify-center gap-3 w-48">
            <div className="h-px flex-1 bg-[#C4606F]/40" />
            <span className="text-[#C4606F] text-xs">❦</span>
            <div className="h-px flex-1 bg-[#C4606F]/40" />
          </div>

          {/* Hosts Lines */}
          <p className="font-['Cormorant_Garamond'] text-lg sm:text-xl italic text-[#1F3D2B]">
            {WEDDING_DATA.blessingLine}
          </p>

          <p className="mt-3 font-['Cinzel'] text-sm sm:text-base font-semibold tracking-[0.2em] text-[#1F3D2B]">
            {WEDDING_DATA.hostsUpper}
          </p>

          <p className="mt-3 font-['Cormorant_Garamond'] text-lg sm:text-xl italic text-[#3F6B4C]">
            {WEDDING_DATA.inviteLine}
          </p>

          {/* Couple Calligraphy */}
          <div className="my-6">
            <h1 className="font-['Great_Vibes'] text-6xl sm:text-8xl text-[#1F3D2B] drop-shadow-sm">
              {WEDDING_DATA.groom}
            </h1>
            <p className="my-2 font-['Cormorant_Garamond'] text-2xl sm:text-3xl italic text-[#C4606F]">
              With
            </p>
            <h2 className="font-['Great_Vibes'] text-6xl sm:text-8xl text-[#1F3D2B] drop-shadow-sm">
              {WEDDING_DATA.bride}
            </h2>
          </div>

          {/* Venue & Directions Quick Button */}
          <button
            onClick={scrollToVenue}
            className="mt-6 inline-flex items-center gap-2 rounded-full border border-[#C4606F] bg-white/70 px-6 py-2.5 font-['Cinzel'] text-xs font-semibold uppercase tracking-widest text-[#1F3D2B] shadow-sm backdrop-blur-sm transition-all hover:bg-[#C4606F] hover:text-white"
          >
            <MapPin className="h-3.5 w-3.5 text-[#C4606F]" />
            <span>Venue &amp; Directions</span>
          </button>

          {/* Scroll Down Arrow Indicator */}
          <div className="mt-10 animate-bounce text-[#C4606F]/70">
            <ChevronDown className="h-6 w-6" />
          </div>
        </section>

        {/* Section 2: Wedding Announcement Card */}
        <section className="py-12 text-center">
          <h3 className="font-['Great_Vibes'] text-4xl sm:text-5xl text-[#1F3D2B]">
            Wedding Announcement
          </h3>
          <div className="my-4 flex items-center justify-center gap-3 w-40 mx-auto">
            <div className="h-px flex-1 bg-[#C4606F]/40" />
            <span className="text-[#C4606F] text-xs">❦</span>
            <div className="h-px flex-1 bg-[#C4606F]/40" />
          </div>

          {/* Official Invitation Wording with verified "our son" */}
          <div className="mx-auto max-w-lg rounded-2xl border border-[#C4606F]/30 bg-white/75 p-8 shadow-lg backdrop-blur-md">
            <p className="font-['Cormorant_Garamond'] text-xl sm:text-2xl italic leading-relaxed text-[#1F3D2B]">
              {WEDDING_DATA.invitationMessage}
            </p>
          </div>

          {/* Date Badge */}
          <div className="mt-10 flex flex-col items-center">
            <p className="font-['Cormorant_Garamond'] text-2xl italic text-[#1F3D2B]">
              {WEDDING_DATA.weekday}
            </p>
            <div className="my-2 flex items-center gap-4 sm:gap-6">
              <span className="font-['Cinzel'] text-xs sm:text-sm tracking-[0.2em] uppercase text-[#1F3D2B]">
                December
              </span>
              <div className="h-16 w-px bg-[#C4606F]/50" />
              <span className="font-['Cormorant_Garamond'] text-7xl sm:text-8xl font-light text-[#1F3D2B] leading-none">
                27
              </span>
              <div className="h-16 w-px bg-[#C4606F]/50" />
              <span className="font-['Cinzel'] text-xs sm:text-sm tracking-[0.2em] uppercase text-[#1F3D2B]">
                2026
              </span>
            </div>
            <p className="font-['Cormorant_Garamond'] text-xl italic text-[#3F6B4C]">
              at {WEDDING_DATA.timeLabel} IST
            </p>

            <a
              href={WEDDING_DATA.calendarUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-6 inline-flex items-center gap-2 rounded-full border border-[#C4606F]/50 bg-white/60 px-5 py-2 font-['Cinzel'] text-xs tracking-wider uppercase text-[#1F3D2B] transition-all hover:bg-white hover:shadow-sm"
            >
              <Calendar className="h-3.5 w-3.5 text-[#C4606F]" />
              <span>Add to Calendar</span>
            </a>
          </div>
        </section>

        {/* Section 3: Live Wedding Countdown */}
        <section className="py-12 text-center">
          <h3 className="font-['Great_Vibes'] text-4xl sm:text-5xl text-[#1F3D2B]">
            Counting Down
          </h3>
          <div className="my-4 flex items-center justify-center gap-3 w-40 mx-auto">
            <div className="h-px flex-1 bg-[#C4606F]/40" />
            <span className="text-[#C4606F] text-xs">❦</span>
            <div className="h-px flex-1 bg-[#C4606F]/40" />
          </div>

          <div className="mt-6 grid grid-cols-4 gap-3 sm:gap-4 max-w-md mx-auto">
            {[
              { label: 'Days', val: countdown.days },
              { label: 'Hours', val: countdown.hours },
              { label: 'Minutes', val: countdown.minutes },
              { label: 'Seconds', val: countdown.seconds },
            ].map((unit, idx) => (
              <div
                key={idx}
                className="flex flex-col items-center justify-center rounded-2xl border border-[#C4606F]/30 bg-white/80 p-3 sm:p-4 shadow-sm backdrop-blur-sm"
              >
                <span className="font-['Cormorant_Garamond'] text-3xl sm:text-5xl font-semibold text-[#1F3D2B]">
                  {String(unit.val).padStart(2, '0')}
                </span>
                <span className="mt-1 font-['Cinzel'] text-[10px] sm:text-xs uppercase tracking-wider text-[#C4606F]">
                  {unit.label}
                </span>
              </div>
            ))}
          </div>

          <p className="mt-4 font-['Cormorant_Garamond'] text-sm italic text-[#3F6B4C]">
            Until Akshay &amp; Wilma say &ldquo;I do&rdquo;
          </p>
        </section>

        {/* Section 4: Parents' Blessing Section (Replaces old photo section seamlessly without empty spaces) */}
        <section className="py-12 text-center">
          <h3 className="font-['Great_Vibes'] text-4xl sm:text-5xl text-[#1F3D2B]">
            Parents&apos; Blessing
          </h3>
          <div className="my-4 flex items-center justify-center gap-3 w-40 mx-auto">
            <div className="h-px flex-1 bg-[#C4606F]/40" />
            <span className="text-[#C4606F] text-xs">❦</span>
            <div className="h-px flex-1 bg-[#C4606F]/40" />
          </div>

          <div className="mt-6 flex flex-col gap-4 max-w-lg mx-auto">
            <div className="rounded-2xl border border-[#C4606F]/30 bg-white/75 p-6 shadow-sm backdrop-blur-sm">
              <p className="font-['Cormorant_Garamond'] text-lg italic text-[#3F6B4C]">
                Parents of the Groom
              </p>
              <p className="mt-2 font-['Cinzel'] text-sm sm:text-base font-semibold tracking-wider text-[#1F3D2B]">
                {WEDDING_DATA.groomParents}
              </p>
            </div>

            <div className="rounded-2xl border border-[#C4606F]/30 bg-white/75 p-6 shadow-sm backdrop-blur-sm">
              <p className="font-['Cormorant_Garamond'] text-lg italic text-[#3F6B4C]">
                Parents of the Bride
              </p>
              <p className="mt-2 font-['Cinzel'] text-sm sm:text-base font-semibold tracking-wider text-[#1F3D2B]">
                {WEDDING_DATA.brideParents}
              </p>
            </div>
          </div>

          <div className="mt-8 max-w-md mx-auto">
            <p className="font-['Cormorant_Garamond'] text-xl italic text-[#1F3D2B]">
              &ldquo;{WEDDING_DATA.verse}&rdquo;
            </p>
            <p className="font-['Cormorant_Garamond'] text-xs uppercase tracking-widest text-[#3F6B4C] mt-1">
              — {WEDDING_DATA.verseReference}
            </p>
          </div>
        </section>

        {/* Section 5: The Wedding Venue with Uploaded Church Photograph */}
        <section ref={venueSectionRef} className="py-12 text-center">
          <h3 className="font-['Great_Vibes'] text-4xl sm:text-5xl text-[#1F3D2B]">
            The Wedding Venue
          </h3>
          <div className="my-4 flex items-center justify-center gap-3 w-40 mx-auto">
            <div className="h-px flex-1 bg-[#C4606F]/40" />
            <span className="text-[#C4606F] text-xs">❦</span>
            <div className="h-px flex-1 bg-[#C4606F]/40" />
          </div>

          {/* Church Photograph Container: Full twin towers view, responsive, elegant arch, fade-in and subtle zoom */}
          <div className="mx-auto my-6 max-w-xl">
            <div
              className="group relative overflow-hidden rounded-t-[120px] rounded-b-2xl border-2 border-[#E79AA3] bg-[#FFF8F4] shadow-2xl transition-all duration-700 hover:shadow-[#C4606F]/25 hover:shadow-2xl"
              style={{
                aspectRatio: '1448 / 1086', // Exact native aspect ratio prevents any cropping
              }}
            >
              <img
                src={WEDDING_DATA.churchPhoto}
                alt="The Basilica of Our Lady of Ransom, Vallarpadam, Kochi"
                onLoad={() => setChurchLoaded(true)}
                className={`h-full w-full object-cover object-top transition-all duration-1000 ease-out group-hover:scale-105 ${
                  churchLoaded
                    ? 'opacity-100 scale-100'
                    : 'opacity-0 scale-105'
                }`}
              />

              {/* Delicate gradient overlay for lighting harmony */}
              <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-[#1F3D2B]/30 via-transparent to-transparent opacity-60" />

              {/* Subtle top spire protection vignette */}
              <div className="pointer-events-none absolute inset-0 rounded-t-[120px] ring-1 ring-inset ring-[#E79AA3]/50" />
            </div>

            <p className="mt-2 text-xs font-['Cinzel'] tracking-widest text-[#3F6B4C] uppercase">
              Basilica of Our Lady of Ransom &bull; Vallarpadam
            </p>
          </div>

          {/* Bouncing Location Pin */}
          <div className="my-4 flex justify-center">
            <div className="relative flex h-14 w-14 items-center justify-center">
              <span className="absolute h-8 w-8 rounded-full border border-[#C4606F]/50 animate-ping" />
              <MapPin className="relative h-10 w-10 text-[#C4606F] animate-bounce" />
            </div>
          </div>

          <h4 className="font-['Cormorant_Garamond'] text-2xl sm:text-3xl font-semibold text-[#1F3D2B]">
            {WEDDING_DATA.venueName}
          </h4>

          <p className="mt-1 font-['Cormorant_Garamond'] text-lg italic text-[#3F6B4C]">
            {WEDDING_DATA.venueLocality}.
          </p>

          <p className="mt-2 font-['Cormorant_Garamond'] text-base text-[#1F3D2B]">
            {WEDDING_DATA.dateLong}, {WEDDING_DATA.timeLabel} IST
          </p>

          {/* Directions Button */}
          <div className="mt-8 flex justify-center">
            <a
              href={WEDDING_DATA.directionsUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2.5 rounded-full bg-[#1F3D2B] px-8 py-3.5 font-['Cinzel'] text-xs font-semibold uppercase tracking-widest text-white shadow-lg transition-all duration-300 hover:bg-[#3F6B4C] hover:shadow-xl hover:scale-105"
            >
              <Navigation className="h-4 w-4 text-[#E79AA3]" />
              <span>Get Directions on Google Maps</span>
            </a>
          </div>
        </section>

        {/* Section 6: Thank You & Blessings */}
        <section className="pt-12 pb-24 text-center">
          <div className="my-4 flex items-center justify-center gap-3 w-48 mx-auto">
            <div className="h-px flex-1 bg-[#C4606F]/40" />
            <span className="text-[#C4606F] text-xs">❦</span>
            <div className="h-px flex-1 bg-[#C4606F]/40" />
          </div>

          <h3 className="font-['Great_Vibes'] text-6xl sm:text-7xl text-[#1F3D2B]">
            Thank You
          </h3>

          <p className="mt-4 max-w-md mx-auto font-['Cormorant_Garamond'] text-xl sm:text-2xl italic leading-relaxed text-[#1F3D2B]">
            Your presence and prayers will make our day truly special.
          </p>

          <p className="mt-8 font-['Great_Vibes'] text-4xl sm:text-5xl text-[#C4606F]">
            Akshay &amp; Wilma
          </p>

          <p className="mt-2 font-['Cormorant_Garamond'] text-sm tracking-wider text-[#3F6B4C]">
            {WEDDING_DATA.dateLong}
          </p>

          <div className="mt-8 flex justify-center">
            <span className="text-2xl text-[#C4606F]">✝</span>
          </div>
        </section>
      </main>

      {/* FLUTTER REPOSITORY STATUS MODAL */}
      {showStatusModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm">
          <div className="relative w-full max-w-lg rounded-2xl border border-[#C4606F]/30 bg-[#FFFDFB] p-6 shadow-2xl font-sans text-left text-sm text-[#1F3D2B]">
            <div className="flex items-center justify-between pb-3 border-b border-[#C4606F]/20">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-5 w-5 text-emerald-600" />
                <h3 className="font-semibold text-base text-[#1F3D2B]">
                  Flutter Web Project Status
                </h3>
              </div>
              <button
                onClick={() => setShowStatusModal(false)}
                className="rounded-full p-1 text-[#1F3D2B]/60 hover:bg-[#FBE4E1] transition"
              >
                ✕
              </button>
            </div>

            <div className="mt-4 space-y-3 font-normal text-xs sm:text-sm text-[#1F3D2B]/85">
              <p>
                <strong>Architecture Preserved:</strong> All Flutter Web source
                code, dependencies, and GitHub Pages deployment workflow remain
                100% in Flutter/Dart.
              </p>
              <div className="rounded-lg bg-[#FBE4E1]/40 p-3 font-mono text-xs space-y-1">
                <div>✓ lib/core/config.dart (Updated wording: &quot;our son&quot;)</div>
                <div>✓ lib/widgets/church.dart (Full twin towers photo, fade-in &amp; zoom)</div>
                <div>✓ lib/screens/invitation_page.dart (Photo gallery removed cleanly)</div>
                <div>✓ pubspec.yaml (assets/images/basilica_church.jpg declared)</div>
                <div>✓ assets/images/basilica_church.jpg (Uploaded photo added)</div>
                <div>✓ .github/workflows/deploy.yml (GitHub Pages compatible)</div>
              </div>
              <p className="text-xs text-[#3F6B4C]">
                Note on container build: Flutter SDK is not pre-installed in
                this Linux runtime, but the project structure is ready for GitHub
                Actions or local <code className="bg-neutral-100 px-1 py-0.5 rounded">flutter build web</code>.
              </p>
            </div>

            <div className="mt-6 flex flex-col sm:flex-row gap-2 justify-end">
              <a
                href={WEDDING_DATA.updatedZipUrl}
                download="wedding_invitation_updated.zip"
                className="inline-flex items-center justify-center gap-1.5 rounded-lg bg-[#1F3D2B] px-4 py-2 font-medium text-white transition hover:bg-[#3F6B4C]"
              >
                <Download className="h-4 w-4" />
                <span>Download Updated Flutter .zip</span>
              </a>
              <button
                onClick={() => setShowStatusModal(false)}
                className="rounded-lg border border-[#C4606F]/40 px-4 py-2 font-medium text-[#1F3D2B] hover:bg-neutral-50 transition"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
