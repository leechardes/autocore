import React from 'react';
import { HelpCircle } from 'lucide-react';

const HelpButtonTest = () => {
  const handleClick = () => {
    alert('Botão de ajuda clicado! A documentação completa está sendo carregada...');
  };

  return (
    <div 
      style={{ 
        position: 'fixed', 
        top: '20px', 
        right: '20px', 
        zIndex: 99999,
        backgroundColor: '#007bff',
        color: 'white',
        padding: '10px 20px',
        borderRadius: '8px',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
      }}
      onClick={handleClick}
    >
      <HelpCircle size={20} />
      <span>Ajuda</span>
    </div>
  );
};

export default HelpButtonTest;