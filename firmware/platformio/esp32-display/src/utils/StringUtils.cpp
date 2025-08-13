#include "utils/StringUtils.h"

String StringUtils::removeAccents(const String& text) {
    String result = "";
    
    for (size_t i = 0; i < text.length(); i++) {
        unsigned char c = text[i];
        
        // Se for um caractere ASCII normal (< 128), apenas adiciona
        if (c < 128) {
            result += (char)c;
            continue;
        }
        
        // Trata caracteres UTF-8 de 2 bytes
        if ((c & 0xE0) == 0xC0 && i + 1 < text.length()) {
            unsigned char c2 = text[i + 1];
            
            // Verifica se é um caractere acentuado comum
            if (c == 0xC3) {  // Prefixo para muitos caracteres latinos
                switch (c2) {
                    // Minúsculas
                    case 0xA0: case 0xA1: case 0xA2: case 0xA3: case 0xA4: case 0xA5: // à á â ã ä å
                        result += 'a'; i++; continue;
                    case 0xA7: // ç
                        result += 'c'; i++; continue;
                    case 0xA8: case 0xA9: case 0xAA: case 0xAB: // è é ê ë
                        result += 'e'; i++; continue;
                    case 0xAC: case 0xAD: case 0xAE: case 0xAF: // ì í î ï
                        result += 'i'; i++; continue;
                    case 0xB1: // ñ
                        result += 'n'; i++; continue;
                    case 0xB2: case 0xB3: case 0xB4: case 0xB5: case 0xB6: // ò ó ô õ ö
                        result += 'o'; i++; continue;
                    case 0xB9: case 0xBA: case 0xBB: case 0xBC: // ù ú û ü
                        result += 'u'; i++; continue;
                    
                    // Maiúsculas
                    case 0x80: case 0x81: case 0x82: case 0x83: case 0x84: case 0x85: // À Á Â Ã Ä Å
                        result += 'A'; i++; continue;
                    case 0x87: // Ç
                        result += 'C'; i++; continue;
                    case 0x88: case 0x89: case 0x8A: case 0x8B: // È É Ê Ë
                        result += 'E'; i++; continue;
                    case 0x8C: case 0x8D: case 0x8E: case 0x8F: // Ì Í Î Ï
                        result += 'I'; i++; continue;
                    case 0x91: // Ñ
                        result += 'N'; i++; continue;
                    case 0x92: case 0x93: case 0x94: case 0x95: case 0x96: // Ò Ó Ô Õ Ö
                        result += 'O'; i++; continue;
                    case 0x99: case 0x9A: case 0x9B: case 0x9C: // Ù Ú Û Ü
                        result += 'U'; i++; continue;
                }
            }
        }
        
        // Se não for um caractere conhecido, substitui por '?'
        result += '?';
    }
    
    return result;
}