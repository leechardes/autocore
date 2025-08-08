import React from 'react';

// Componente do ícone AutoCore (apenas o hexágono com conexões)
export const AutoCoreIcon = ({ className = "", size = 48 }) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    className={className}
    xmlns="http://www.w3.org/2000/svg"
  >
    {/* Hexágono externo laranja */}
    <path
      d="M50 10 L80 27.5 L80 72.5 L50 90 L20 72.5 L20 27.5 Z"
      fill="none"
      stroke="#FF7A59"
      strokeWidth="4"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    
    {/* Hexágono interno azul */}
    <path
      d="M50 25 L70 37.5 L70 62.5 L50 75 L30 62.5 L30 37.5 Z"
      fill="#4A90E2"
    />
    
    {/* Conexões laterais */}
    {/* Esquerda */}
    <line x1="30" y1="40" x2="10" y2="40" stroke="#4A90E2" strokeWidth="3" />
    <circle cx="10" cy="40" r="4" fill="#FF7A59" />
    
    <line x1="30" y1="50" x2="10" y2="50" stroke="#4A90E2" strokeWidth="3" />
    <circle cx="10" cy="50" r="4" fill="#FF7A59" />
    
    <line x1="30" y1="60" x2="10" y2="60" stroke="#4A90E2" strokeWidth="3" />
    <circle cx="10" cy="60" r="4" fill="#FF7A59" />
    
    {/* Direita */}
    <line x1="70" y1="40" x2="90" y2="40" stroke="#4A90E2" strokeWidth="3" />
    <circle cx="90" cy="40" r="4" fill="#FF7A59" />
    
    <line x1="70" y1="50" x2="90" y2="50" stroke="#4A90E2" strokeWidth="3" />
    <circle cx="90" cy="50" r="4" fill="#FF7A59" />
    
    <line x1="70" y1="60" x2="90" y2="60" stroke="#4A90E2" strokeWidth="3" />
    <circle cx="90" cy="60" r="4" fill="#FF7A59" />
  </svg>
);

// Componente do logo completo (ícone + texto)
export const AutoCoreLogo = ({ 
  className = "", 
  showText = true, 
  showSubtitle = true,
  iconSize = 48,
  textSize = "text-3xl",
  subtitleSize = "text-sm"
}) => (
  <div className={`flex items-center gap-3 ${className}`}>
    <AutoCoreIcon size={iconSize} />
    {showText && (
      <div>
        <h1 className={`font-bold text-gray-800 dark:text-white ${textSize}`}>
          AutoCore
        </h1>
        {showSubtitle && (
          <p className={`text-gray-600 dark:text-gray-400 ${subtitleSize}`}>
            Smart Vehicle Gateway
          </p>
        )}
      </div>
    )}
  </div>
);

// Componente minimalista para uso em headers
export const AutoCoreLogoCompact = ({ className = "" }) => (
  <div className={`flex items-center gap-2 ${className}`}>
    <AutoCoreIcon size={32} />
    <span className="font-semibold text-lg">AutoCore</span>
  </div>
);

export default AutoCoreLogo;