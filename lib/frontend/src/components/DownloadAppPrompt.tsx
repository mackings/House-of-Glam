interface DownloadAppPromptProps {
  title?: string;
  description?: string;
}

export default function DownloadAppPrompt({
  title = "New to House of GLAME?",
  description = "Create an account, place custom orders, and manage everything from the House of GLAME app.",
}: DownloadAppPromptProps) {
  return (
    <div className="rounded-2xl border border-border bg-surface-muted p-5">
      <p className="font-display text-base font-bold text-ink">{title}</p>
      <p className="mt-1.5 text-sm leading-relaxed text-subtext">
        {description}
      </p>
      <div className="mt-4 flex flex-wrap gap-3">
        <span className="inline-flex cursor-not-allowed items-center gap-2 rounded-full bg-ink/90 px-4 py-2.5 text-xs font-semibold text-white opacity-60">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.53 4.08zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
          </svg>
          App Store — Coming Soon
        </span>
        <span className="inline-flex cursor-not-allowed items-center gap-2 rounded-full bg-ink/90 px-4 py-2.5 text-xs font-semibold text-white opacity-60">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M3.6 2.4c-.35.35-.55.9-.55 1.6v16c0 .7.2 1.25.55 1.6l.1.1L13 12.4v-.2L3.7 2.3l-.1.1z" />
            <path d="M16.1 15.5 13 12.4v-.2l3.1-3.1 6.9 3.9c.55.32.9.75.9 1.15 0 .4-.35.83-.9 1.15z" />
            <path d="M13 12.2l3.1-3.1 6.9-3.9c.55-.32.9-.75.9-1.15 0-.4-.35-.83-.9-1.15L16.1 6z" />
            <path d="M3.7 21.9c.3.2.75.15 1.25-.1L16.1 15.5 13 12.4z" />
          </svg>
          Google Play — Coming Soon
        </span>
      </div>
    </div>
  );
}
