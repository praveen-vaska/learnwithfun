// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final assets = <String, String>{
    // Existing base illustrations
    'assets/images/logo.svg': '''<svg viewBox="0 0 400 120" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="gradP" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#8B5CF6"/>
      <stop offset="100%" stop-color="#6D28D9"/>
    </linearGradient>
    <linearGradient id="gradY" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FCD34D"/>
      <stop offset="100%" stop-color="#F59E0B"/>
    </linearGradient>
  </defs>
  <g transform="translate(10, 10)">
    <circle cx="50" cy="50" r="45" fill="url(#gradP)"/>
    <path d="M 25 65 Q 50 55 50 35 Q 50 55 75 65 L 75 40 Q 50 30 50 15 Q 50 30 25 40 Z" fill="#FFF4E9"/>
    <circle cx="50" cy="30" r="14" fill="#FFE16A"/>
    <circle cx="45" cy="28" r="2" fill="#292536"/>
    <circle cx="55" cy="28" r="2" fill="#292536"/>
    <path d="M 47 34 Q 50 37 53 34" stroke="#292536" stroke-width="1.5" stroke-linecap="round" fill="none"/>
  </g>
  <text x="120" y="55" font-family="Nunito, Arial, sans-serif" font-weight="900" font-size="38" fill="#7952F5">Learn</text>
  <text x="235" y="55" font-family="Nunito, Arial, sans-serif" font-weight="900" font-size="38" fill="#F59E0B">With</text>
  <text x="325" y="55" font-family="Nunito, Arial, sans-serif" font-weight="900" font-size="38" fill="#10B981">Fun</text>
  <text x="122" y="85" font-family="Nunito, Arial, sans-serif" font-weight="700" font-size="16" fill="#8B5CF6" letter-spacing="1.5">KIDS SMART LEARNING APP</text>
  <path d="M 380 25 Q 385 15 390 25 Q 385 35 380 25 Z" fill="#FFE16A"/>
  <path d="M 115 20 Q 118 12 121 20 Q 118 28 115 20 Z" fill="#FFB7CB"/>
</svg>''',

    'assets/images/hero_reading.svg': '''<svg viewBox="0 0 400 360" xmlns="http://www.w3.org/2000/svg">
  <circle cx="200" cy="180" r="140" fill="#E9D5FF" opacity="0.4"/>
  <path d="M 50 320 Q 80 270 140 290 Q 200 260 260 290 Q 320 270 350 320 Z" fill="#FFFFFF" opacity="0.9"/>
  <g transform="translate(60, 80)">
    <path d="M 50 40 C 20 40 25 100 35 120 C 50 140 110 140 125 120 C 135 100 140 40 110 40 Z" fill="#78350F"/>
    <ellipse cx="80" cy="90" rx="42" ry="45" fill="#FED7AA"/>
    <circle cx="66" cy="90" r="6" fill="#1F2937"/><circle cx="94" cy="90" r="6" fill="#1F2937"/>
    <path d="M 72 104 Q 80 112 88 104" stroke="#991B1B" stroke-width="3" stroke-linecap="round" fill="none"/>
    <path d="M 45 130 C 35 145 35 190 35 220 L 125 220 C 125 190 125 145 115 130 Z" fill="#FBBF24"/>
  </g>
  <g transform="translate(250, 150)">
    <circle cx="40" cy="50" r="16" fill="#1F2937"/><circle cx="100" cy="50" r="16" fill="#1F2937"/>
    <ellipse cx="70" cy="85" rx="42" ry="38" fill="#FFFFFF" stroke="#E5E7EB" stroke-width="2"/>
    <ellipse cx="54" cy="80" rx="12" ry="15" fill="#1F2937" transform="rotate(-15 54 80)"/>
    <ellipse cx="86" cy="80" rx="12" ry="15" fill="#1F2937" transform="rotate(15 86 80)"/>
    <circle cx="56" cy="80" r="4" fill="#FFFFFF"/><circle cx="84" cy="80" r="4" fill="#FFFFFF"/>
    <ellipse cx="70" cy="94" rx="6" ry="4" fill="#1F2937"/>
    <circle cx="42" cy="95" r="7" fill="#F472B6" opacity="0.6"/><circle cx="98" cy="95" r="7" fill="#F472B6" opacity="0.6"/>
  </g>
</svg>''',

    'assets/images/boy_rocket.svg': '''<svg viewBox="0 0 400 360" xmlns="http://www.w3.org/2000/svg">
  <circle cx="90" cy="120" r="40" fill="#EDE9FE" opacity="0.6"/>
  <g transform="translate(190, 180) rotate(-35) translate(-100, -120)">
    <path d="M 80 180 Q 100 250 100 270 Q 100 250 120 180 Z" fill="#F97316"/>
    <path d="M 60 140 L 40 180 L 75 170 Z" fill="#3B82F6"/>
    <path d="M 140 140 L 160 180 L 125 170 Z" fill="#3B82F6"/>
    <path d="M 70 170 L 70 80 Q 100 10 130 80 L 130 170 Z" fill="#EF4444"/>
    <circle cx="100" cy="100" r="22" fill="#93C5FD" stroke="#FFFFFF" stroke-width="5"/>
    <circle cx="100" cy="96" r="12" fill="#FED7AA"/>
  </g>
</svg>''',

    'assets/images/girl_learning.svg': '''<svg viewBox="0 0 400 360" xmlns="http://www.w3.org/2000/svg">
  <circle cx="200" cy="180" r="130" fill="#F3E8FF"/>
  <circle cx="200" cy="60" r="22" fill="#FDE047"/>
  <g transform="translate(140, 190)">
    <rect x="0" y="50" width="120" height="22" rx="4" fill="#3B82F6"/>
    <rect x="15" y="30" width="95" height="20" rx="4" fill="#10B981"/>
    <rect x="25" y="12" width="80" height="18" rx="4" fill="#F97316"/>
  </g>
  <circle cx="200" cy="150" r="38" fill="#FED7AA"/>
  <circle cx="186" cy="148" r="4" fill="#1F2937"/><circle cx="214" cy="148" r="4" fill="#1F2937"/>
  <path d="M 192 160 Q 200 168 208 160" stroke="#DC2626" stroke-width="2.5" fill="none"/>
</svg>''',

    'assets/images/golden_trophy.svg': '''<svg viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg">
  <path d="M 60 70 C 40 70 40 130 90 140" stroke="#F59E0B" stroke-width="14" stroke-linecap="round" fill="none"/>
  <path d="M 240 70 C 260 70 260 130 210 140" stroke="#F59E0B" stroke-width="14" stroke-linecap="round" fill="none"/>
  <path d="M 80 50 L 220 50 C 220 120 190 170 150 170 C 110 170 80 120 80 50 Z" fill="#F59E0B"/>
  <ellipse cx="150" cy="50" rx="70" ry="12" fill="#FEF08A"/>
  <polygon points="150,85 155,100 170,100 158,110 162,125 150,115 138,125 142,110 130,100 145,100" fill="#FFFFFF"/>
  <rect x="140" y="170" width="20" height="40" fill="#D97706"/>
  <rect x="110" y="210" width="80" height="35" rx="6" fill="#1F2937"/>
</svg>''',

    'assets/images/fairytale_castle.svg': '''<svg viewBox="0 0 400 360" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="200" cy="270" rx="160" ry="60" fill="#34D399"/>
  <rect x="170" y="130" width="60" height="90" fill="#DB2777"/>
  <polygon points="200,60 160,130 240,130" fill="#8B5CF6"/>
  <rect x="120" y="150" width="40" height="70" fill="#F472B6"/>
  <polygon points="140,95 110,150 170,150" fill="#8B5CF6"/>
  <rect x="240" y="150" width="40" height="70" fill="#F472B6"/>
  <polygon points="260,95 230,150 290,150" fill="#8B5CF6"/>
</svg>''',

    'assets/images/apple_illustration.svg': '''<svg viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg">
  <path d="M 150 75 Q 165 40 180 35" stroke="#5D4037" stroke-width="8" stroke-linecap="round" fill="none"/>
  <path d="M 155 60 C 185 40 215 50 215 65 C 185 85 165 75 155 60 Z" fill="#2E7D32"/>
  <path d="M 150 85 C 110 55 60 75 60 145 C 60 215 110 255 150 255 C 190 255 240 215 240 145 C 240 75 190 55 150 85 Z" fill="#E53935"/>
  <ellipse cx="105" cy="115" rx="20" ry="35" fill="#FFFFFF" opacity="0.4" transform="rotate(-30 105 115)"/>
</svg>''',

    'assets/images/scenic_meadow.svg': '''<svg viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="200" fill="#7DD3FC"/>
  <circle cx="340" cy="45" r="28" fill="#FDE047"/>
  <path d="M -20 150 Q 120 90 260 140 Q 340 120 420 150 L 420 200 L -20 200 Z" fill="#86EFAC"/>
  <path d="M -20 170 Q 150 130 320 160 Q 380 150 420 170 L 420 200 L -20 200 Z" fill="#22C55E"/>
</svg>''',

    'assets/images/gift_box.svg': '''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="70" width="120" height="95" rx="12" fill="#E11D48"/>
  <rect x="32" y="55" width="136" height="25" rx="8" fill="#F43F5E"/>
  <rect x="88" y="55" width="24" height="110" fill="#FDE047"/>
  <ellipse cx="78" cy="45" rx="18" ry="12" fill="#FDE047" transform="rotate(-25 78 45)"/>
  <ellipse cx="122" cy="45" rx="18" ry="12" fill="#FDE047" transform="rotate(25 122 45)"/>
</svg>''',

    // Avatars
    'assets/images/avatars/avatar_boy_1.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><circle cx="80" cy="80" r="75" fill="#EFF6FF"/><circle cx="80" cy="72" r="50" fill="#78350F"/><circle cx="80" cy="82" r="40" fill="#FED7AA"/><circle cx="67" cy="82" r="5" fill="#1F2937"/><circle cx="93" cy="82" r="5" fill="#1F2937"/><path d="M 72 96 Q 80 104 88 96" stroke="#B91C1C" stroke-width="2.5" fill="none"/><path d="M 50 135 C 50 115 110 115 110 135 Z" fill="#3B82F6"/></svg>''',
    'assets/images/avatars/avatar_girl_1.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><circle cx="80" cy="80" r="75" fill="#FFF1F2"/><circle cx="35" cy="70" r="20" fill="#B45309"/><circle cx="125" cy="70" r="20" fill="#B45309"/><circle cx="80" cy="82" r="40" fill="#FED7AA"/><circle cx="67" cy="82" r="5" fill="#1F2937"/><circle cx="93" cy="82" r="5" fill="#1F2937"/><path d="M 72 96 Q 80 104 88 96" stroke="#B91C1C" stroke-width="2.5" fill="none"/><path d="M 50 135 C 50 115 110 115 110 135 Z" fill="#EF4444"/></svg>''',
    'assets/images/avatars/avatar_boy_cap.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><circle cx="80" cy="80" r="75" fill="#F0FDF4"/><circle cx="80" cy="54" r="36" fill="#2563EB"/><circle cx="80" cy="86" r="38" fill="#FED7AA"/><circle cx="67" cy="84" r="5" fill="#1F2937"/><circle cx="93" cy="84" r="5" fill="#1F2937"/><path d="M 72 98 Q 80 106 88 98" stroke="#B91C1C" stroke-width="2.5" fill="none"/><path d="M 50 138 C 50 118 110 118 110 138 Z" fill="#10B981"/></svg>''',
    'assets/images/avatars/avatar_girl_glasses.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><circle cx="80" cy="80" r="75" fill="#FAF5FF"/><circle cx="80" cy="72" r="48" fill="#581C87"/><circle cx="80" cy="82" r="38" fill="#FED7AA"/><circle cx="66" cy="82" r="14" fill="none" stroke="#7C3AED" stroke-width="3"/><circle cx="94" cy="82" r="14" fill="none" stroke="#7C3AED" stroke-width="3"/><path d="M 74 98 Q 80 104 86 98" stroke="#B91C1C" stroke-width="2.5" fill="none"/><path d="M 50 135 C 50 115 110 115 110 135 Z" fill="#8B5CF6"/></svg>''',
    'assets/images/avatars/avatar_panda.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><circle cx="80" cy="80" r="75" fill="#F8FAFC"/><circle cx="45" cy="45" r="18" fill="#1F2937"/><circle cx="115" cy="45" r="18" fill="#1F2937"/><circle cx="80" cy="85" r="46" fill="#FFFFFF"/><ellipse cx="62" cy="82" rx="13" ry="16" fill="#1F2937"/><ellipse cx="98" cy="82" rx="13" ry="16" fill="#1F2937"/><circle cx="64" cy="82" r="4" fill="#FFFFFF"/><circle cx="96" cy="82" r="4" fill="#FFFFFF"/><ellipse cx="80" cy="98" rx="6" ry="4" fill="#1F2937"/></svg>''',
    'assets/images/avatars/avatar_lion.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><circle cx="80" cy="80" r="75" fill="#FEFCE8"/><circle cx="80" cy="80" r="52" fill="#F59E0B"/><circle cx="80" cy="82" r="38" fill="#FDE047"/><circle cx="67" cy="80" r="5" fill="#1F2937"/><circle cx="93" cy="80" r="5" fill="#1F2937"/><path d="M 74 94 Q 80 98 86 94" stroke="#78350F" stroke-width="2" fill="none"/></svg>''',

    // Category Tiles
    'assets/images/categories/cat_alphabet.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#FEE2E2"/><rect x="22" y="30" width="36" height="36" rx="8" fill="#EF4444"/><text x="32" y="56" font-family="Nunito" font-weight="900" font-size="24" fill="#FFFFFF">A</text><rect x="62" y="22" width="36" height="36" rx="8" fill="#3B82F6"/><text x="73" y="48" font-family="Nunito" font-weight="900" font-size="24" fill="#FFFFFF">B</text><rect x="42" y="60" width="36" height="36" rx="8" fill="#10B981"/><text x="52" y="86" font-family="Nunito" font-weight="900" font-size="24" fill="#FFFFFF">C</text></svg>''',
    'assets/images/categories/cat_numbers.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#E0E7FF"/><text x="20" y="55" font-family="Nunito" font-weight="900" font-size="34" fill="#3B82F6">1</text><text x="50" y="75" font-family="Nunito" font-weight="900" font-size="38" fill="#EC4899">2</text><text x="82" y="95" font-family="Nunito" font-weight="900" font-size="42" fill="#F59E0B">3</text></svg>''',
    'assets/images/categories/cat_animals.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#FEF3C7"/><circle cx="60" cy="60" r="38" fill="#F59E0B"/><circle cx="60" cy="62" r="28" fill="#FDE047"/><circle cx="50" cy="58" r="4" fill="#1F2937"/><circle cx="70" cy="58" r="4" fill="#1F2937"/><path d="M 55 70 Q 60 74 65 70" stroke="#92400E" stroke-width="2" fill="none"/></svg>''',
    'assets/images/categories/cat_shapes.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#F3E8FF"/><circle cx="40" cy="45" r="18" fill="#EC4899"/><polygon points="85,30 68,60 102,60" fill="#3B82F6"/><rect x="42" y="66" width="36" height="36" rx="6" fill="#F59E0B"/></svg>''',
    'assets/images/categories/cat_fruits.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#DCFCE7"/><circle cx="48" cy="65" r="22" fill="#EF4444"/><path d="M 85 45 L 60 90 L 80 85 Z" fill="#F97316"/></svg>''',
    'assets/images/categories/cat_birds.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#E0F2FE"/><ellipse cx="60" cy="65" rx="26" ry="22" fill="#38BDF8"/><circle cx="75" cy="52" r="16" fill="#38BDF8"/><polygon points="88,52 102,56 88,60" fill="#F97316"/></svg>''',
    'assets/images/categories/cat_vehicles.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#FEE2E2"/><path d="M 25 75 L 35 55 L 75 55 L 95 75 Z" fill="#EF4444"/><rect x="20" y="72" width="80" height="18" rx="6" fill="#DC2626"/><circle cx="40" cy="90" r="10" fill="#1F2937"/><circle cx="80" cy="90" r="10" fill="#1F2937"/></svg>''',
    'assets/images/categories/cat_body.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#FDF4FF"/><circle cx="60" cy="40" r="18" fill="#FED7AA"/><rect x="48" y="58" width="24" height="32" rx="6" fill="#8B5CF6"/><line x1="72" y1="62" x2="90" y2="45" stroke="#FED7AA" stroke-width="6" stroke-linecap="round"/></svg>''',
    'assets/images/categories/cat_science.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="28" fill="#CCFBF1"/><path d="M 55 35 L 65 35 L 65 50 L 85 85 C 88 90 85 95 78 95 L 42 95 C 35 95 32 90 35 85 L 55 50 Z" fill="#06B6D4"/><circle cx="60" cy="75" r="4" fill="#FFFFFF"/></svg>''',

    // Full Animal Illustrations
    'assets/images/animals/animal_cow.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#F8FAFC"/><ellipse cx="80" cy="80" rx="42" ry="38" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="2"/><path d="M 50 60 Q 65 55 60 75 Q 45 80 50 60 Z" fill="#1F2937"/><circle cx="62" cy="75" r="4" fill="#1F2937"/><circle cx="98" cy="75" r="4" fill="#1F2937"/><ellipse cx="80" cy="100" rx="28" ry="16" fill="#FBCFE8"/><ellipse cx="72" cy="100" rx="4" ry="5" fill="#9D174D"/><ellipse cx="88" cy="100" rx="4" ry="5" fill="#9D174D"/></svg>''',
    'assets/images/animals/animal_cat.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#FFF7ED"/><polygon points="45,65 35,30 65,50" fill="#F97316"/><polygon points="115,65 125,30 95,50" fill="#F97316"/><circle cx="80" cy="85" r="40" fill="#FB923C"/><circle cx="64" cy="82" r="5" fill="#1F2937"/><circle cx="96" cy="82" r="5" fill="#1F2937"/><polygon points="80,92 76,87 84,87" fill="#F43F5E"/></svg>''',
    'assets/images/animals/animal_lion.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#FEFCE8"/><circle cx="80" cy="80" r="50" fill="#F59E0B"/><circle cx="80" cy="84" r="36" fill="#FDE047"/><circle cx="68" cy="80" r="4.5" fill="#1F2937"/><circle cx="92" cy="80" r="4.5" fill="#1F2937"/><polygon points="80,90 74,84 86,84" fill="#92400E"/></svg>''',
    'assets/images/animals/animal_duck.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#F0FDFA"/><ellipse cx="75" cy="95" rx="36" ry="26" fill="#FACC15"/><circle cx="95" cy="70" r="22" fill="#FACC15"/><polygon points="112,68 135,74 112,80" fill="#F97316"/><circle cx="100" cy="66" r="4" fill="#1F2937"/></svg>''',
    'assets/images/animals/animal_dog.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#FFFBEB"/><ellipse cx="40" cy="80" rx="14" ry="26" fill="#92400E"/><ellipse cx="120" cy="80" rx="14" ry="26" fill="#92400E"/><circle cx="80" cy="82" r="42" fill="#D97706"/><circle cx="66" cy="78" r="5" fill="#1F2937"/><circle cx="94" cy="78" r="5" fill="#1F2937"/><ellipse cx="80" cy="94" rx="14" ry="10" fill="#FDE68A"/><ellipse cx="80" cy="90" rx="7" ry="5" fill="#1F2937"/></svg>''',
    'assets/images/animals/animal_sheep.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#F1F5F9"/><circle cx="60" cy="70" r="22" fill="#E2E8F0"/><circle cx="100" cy="70" r="22" fill="#E2E8F0"/><circle cx="80" cy="60" r="24" fill="#E2E8F0"/><circle cx="80" cy="95" r="26" fill="#E2E8F0"/><ellipse cx="80" cy="88" rx="20" ry="22" fill="#1F2937"/><circle cx="72" cy="84" r="3" fill="#FFFFFF"/><circle cx="88" cy="84" r="3" fill="#FFFFFF"/></svg>''',
    'assets/images/animals/animal_elephant.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#F8FAFC"/><circle cx="45" cy="75" r="24" fill="#94A3B8"/><circle cx="115" cy="75" r="24" fill="#94A3B8"/><circle cx="80" cy="80" r="38" fill="#CBD5E1"/><circle cx="68" cy="74" r="4" fill="#1F2937"/><circle cx="92" cy="74" r="4" fill="#1F2937"/><path d="M 80 84 Q 80 120 65 125" stroke="#94A3B8" stroke-width="12" stroke-linecap="round" fill="none"/></svg>''',
    'assets/images/animals/animal_monkey.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#FEFCE8"/><circle cx="40" cy="80" r="16" fill="#78350F"/><circle cx="120" cy="80" r="16" fill="#78350F"/><circle cx="80" cy="80" r="42" fill="#78350F"/><ellipse cx="80" cy="86" rx="30" ry="24" fill="#FED7AA"/><circle cx="68" cy="78" r="5" fill="#1F2937"/><circle cx="92" cy="78" r="5" fill="#1F2937"/><path d="M 72 96 Q 80 102 88 96" stroke="#B91C1C" stroke-width="3" stroke-linecap="round" fill="none"/></svg>''',
    'assets/images/animals/animal_frog.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#ECFDF5"/><ellipse cx="80" cy="90" rx="42" ry="30" fill="#22C55E"/><circle cx="60" cy="65" r="14" fill="#22C55E"/><circle cx="100" cy="65" r="14" fill="#22C55E"/><circle cx="60" cy="65" r="6" fill="#1F2937"/><circle cx="100" cy="65" r="6" fill="#1F2937"/><path d="M 65 96 Q 80 106 95 96" stroke="#14532D" stroke-width="3" fill="none"/></svg>''',
    'assets/images/animals/animal_rabbit.svg': '''<svg viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg"><rect width="160" height="160" rx="24" fill="#FDF2F8"/><ellipse cx="62" cy="45" rx="10" ry="28" fill="#FCE7F3" stroke="#F472B6" stroke-width="2"/><ellipse cx="98" cy="45" rx="10" ry="28" fill="#FCE7F3" stroke="#F472B6" stroke-width="2"/><circle cx="80" cy="88" r="38" fill="#FFFFFF"/><circle cx="68" cy="82" r="4.5" fill="#1F2937"/><circle cx="92" cy="82" r="4.5" fill="#1F2937"/><polygon points="80,94 75,90 85,90" fill="#EC4899"/></svg>''',

    // Numbers (1 to 10)
    'assets/images/numbers/num_1.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#E0E7FF"/><text x="42" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#3B82F6">1</text><circle cx="60" cy="100" r="6" fill="#3B82F6"/></svg>''',
    'assets/images/numbers/num_2.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FEE2E2"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#EF4444">2</text><circle cx="48" cy="100" r="5" fill="#EF4444"/><circle cx="72" cy="100" r="5" fill="#EF4444"/></svg>''',
    'assets/images/numbers/num_3.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#DCFCE7"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#10B981">3</text><circle cx="36" cy="100" r="5" fill="#10B981"/><circle cx="60" cy="100" r="5" fill="#10B981"/><circle cx="84" cy="100" r="5" fill="#10B981"/></svg>''',
    'assets/images/numbers/num_4.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FEF3C7"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#F59E0B">4</text></svg>''',
    'assets/images/numbers/num_5.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#F3E8FF"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#8B5CF6">5</text></svg>''',
    'assets/images/numbers/num_6.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#E0F2FE"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#0284C7">6</text></svg>''',
    'assets/images/numbers/num_7.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FDF4FF"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#D946EF">7</text></svg>''',
    'assets/images/numbers/num_8.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFEDD5"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#F97316">8</text></svg>''',
    'assets/images/numbers/num_9.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#CCFBF1"/><text x="40" y="80" font-family="Nunito" font-weight="900" font-size="64" fill="#0D9488">9</text></svg>''',
    'assets/images/numbers/num_10.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FEE2E2"/><text x="24" y="80" font-family="Nunito" font-weight="900" font-size="54" fill="#DC2626">10</text></svg>''',

    // Shapes
    'assets/images/shapes/shape_circle.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFF1F2"/><circle cx="60" cy="60" r="38" fill="#F43F5E"/></svg>''',
    'assets/images/shapes/shape_square.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#EFF6FF"/><rect x="25" y="25" width="70" height="70" rx="10" fill="#3B82F6"/></svg>''',
    'assets/images/shapes/shape_triangle.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FEFCE8"/><polygon points="60,20 18,95 102,95" fill="#EAB308"/></svg>''',
    'assets/images/shapes/shape_star.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FEF3C7"/><polygon points="60,18 72,48 104,48 78,68 88,98 60,80 32,98 42,68 16,48 48,48" fill="#F59E0B"/></svg>''',
    'assets/images/shapes/shape_heart.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFF1F2"/><path d="M 60 95 C 20 65 20 35 45 35 C 55 35 60 42 60 42 C 60 42 65 35 75 35 C 100 35 100 65 60 95 Z" fill="#EF4444"/></svg>''',
    'assets/images/shapes/shape_diamond.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#F3E8FF"/><polygon points="60,15 100,60 60,105 20,60" fill="#A855F7"/></svg>''',

    // Fruits
    'assets/images/fruits/fruit_banana.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FEFCE8"/><path d="M 30 90 Q 75 90 90 30 Q 80 40 40 70 Z" fill="#FACC15"/><path d="M 90 30 L 95 24" stroke="#713F12" stroke-width="4"/></svg>''',
    'assets/images/fruits/fruit_orange.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFF7ED"/><circle cx="60" cy="65" r="35" fill="#F97316"/><path d="M 60 30 Q 64 22 70 20" stroke="#15803D" stroke-width="4"/></svg>''',
    'assets/images/fruits/fruit_grapes.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FAF5FF"/><circle cx="50" cy="50" r="12" fill="#7E22CE"/><circle cx="70" cy="50" r="12" fill="#7E22CE"/><circle cx="40" cy="68" r="12" fill="#7E22CE"/><circle cx="60" cy="68" r="12" fill="#7E22CE"/><circle cx="80" cy="68" r="12" fill="#7E22CE"/><circle cx="50" cy="86" r="12" fill="#7E22CE"/><circle cx="70" cy="86" r="12" fill="#7E22CE"/><circle cx="60" cy="100" r="10" fill="#7E22CE"/></svg>''',
    'assets/images/fruits/fruit_strawberry.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFF1F2"/><path d="M 60 100 C 25 70 30 35 60 40 C 90 35 95 70 60 100 Z" fill="#E11D48"/><circle cx="50" cy="55" r="2" fill="#FEF08A"/><circle cx="70" cy="55" r="2" fill="#FEF08A"/><circle cx="60" cy="70" r="2" fill="#FEF08A"/></svg>''',

    // Birds
    'assets/images/birds/bird_parrot.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#ECFDF5"/><ellipse cx="55" cy="65" rx="24" ry="32" fill="#16A34A"/><circle cx="60" cy="42" r="18" fill="#22C55E"/><path d="M 72 40 Q 88 45 78 55 Z" fill="#EF4444"/><circle cx="65" cy="38" r="3" fill="#1F2937"/></svg>''',
    'assets/images/birds/bird_owl.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFFBEB"/><circle cx="60" cy="60" r="35" fill="#78350F"/><circle cx="48" cy="55" r="12" fill="#FEF08A"/><circle cx="72" cy="55" r="12" fill="#FEF08A"/><circle cx="48" cy="55" r="5" fill="#1F2937"/><circle cx="72" cy="55" r="5" fill="#1F2937"/><polygon points="60,65 55,72 65,72" fill="#F59E0B"/></svg>''',

    // Vehicles
    'assets/images/vehicles/veh_bus.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FEFCE8"/><rect x="20" y="40" width="80" height="45" rx="8" fill="#FACC15"/><rect x="25" y="46" width="18" height="15" rx="2" fill="#38BDF8"/><rect x="50" y="46" width="18" height="15" rx="2" fill="#38BDF8"/><rect x="75" y="46" width="18" height="15" rx="2" fill="#38BDF8"/><circle cx="40" cy="85" r="9" fill="#1F2937"/><circle cx="80" cy="85" r="9" fill="#1F2937"/></svg>''',
    'assets/images/vehicles/veh_plane.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#E0F2FE"/><ellipse cx="60" cy="60" rx="42" ry="14" fill="#3B82F6"/><polygon points="50,46 40,20 70,46" fill="#1D4ED8"/><polygon points="50,74 40,100 70,74" fill="#1D4ED8"/><polygon points="90,56 105,38 105,56" fill="#1D4ED8"/></svg>''',

    // Body
    'assets/images/body/body_eyes.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FAF5FF"/><ellipse cx="42" cy="60" rx="18" ry="12" fill="#FFFFFF" stroke="#1F2937" stroke-width="2"/><ellipse cx="78" cy="60" rx="18" ry="12" fill="#FFFFFF" stroke="#1F2937" stroke-width="2"/><circle cx="42" cy="60" r="7" fill="#2563EB"/><circle cx="78" cy="60" r="7" fill="#2563EB"/><circle cx="44" cy="58" r="2.5" fill="#FFFFFF"/><circle cx="80" cy="58" r="2.5" fill="#FFFFFF"/></svg>''',
    'assets/images/body/body_hand.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFF7ED"/><path d="M 45 75 L 45 45 C 45 40 52 40 52 45 L 52 70 M 52 45 L 52 35 C 52 30 60 30 60 35 L 60 70 M 60 38 L 60 38 C 60 32 68 32 68 38 L 68 70 M 68 45 C 68 40 75 40 75 45 L 75 75 C 75 92 45 92 45 75 Z" fill="#FED7AA" stroke="#EA580C" stroke-width="2"/></svg>''',

    // Science
    'assets/images/science/sci_sun.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#FFFBEB"/><circle cx="60" cy="60" r="26" fill="#F59E0B"/><circle cx="60" cy="60" r="22" fill="#FDE047"/><g stroke="#F59E0B" stroke-width="4" stroke-linecap="round"><line x1="60" y1="18" x2="60" y2="28"/><line x1="60" y1="92" x2="60" y2="102"/><line x1="18" y1="60" x2="28" y2="60"/><line x1="92" y1="60" x2="102" y2="60"/></g></svg>''',
    'assets/images/science/sci_rainbow.svg': '''<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><rect width="120" height="120" rx="24" fill="#F0FDFA"/><path d="M 20 85 A 40 40 0 0 1 100 85" stroke="#EF4444" stroke-width="6" fill="none"/><path d="M 26 85 A 34 34 0 0 1 94 85" stroke="#F59E0B" stroke-width="6" fill="none"/><path d="M 32 85 A 28 28 0 0 1 88 85" stroke="#10B981" stroke-width="6" fill="none"/><path d="M 38 85 A 22 22 0 0 1 82 85" stroke="#3B82F6" stroke-width="6" fill="none"/><ellipse cx="25" cy="85" rx="14" ry="10" fill="#E2E8F0"/><ellipse cx="95" cy="85" rx="14" ry="10" fill="#E2E8F0"/></svg>''',

    // Stories
    'assets/images/stories/story_lion_mouse.svg': '''<svg viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg"><rect width="200" height="140" rx="16" fill="#FEF3C7"/><circle cx="85" cy="75" r="40" fill="#F59E0B"/><circle cx="85" cy="78" r="30" fill="#FDE047"/><circle cx="75" cy="74" r="4" fill="#1F2937"/><circle cx="95" cy="74" r="4" fill="#1F2937"/><ellipse cx="145" cy="98" rx="16" ry="12" fill="#9CA3AF"/></svg>''',
    'assets/images/stories/story_fox.svg': '''<svg viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg"><rect width="200" height="140" rx="16" fill="#FFEDD5"/><circle cx="100" cy="75" r="35" fill="#F97316"/><polygon points="100,105 75,75 125,75" fill="#FFF7ED"/><circle cx="86" cy="70" r="4" fill="#1F2937"/><circle cx="114" cy="70" r="4" fill="#1F2937"/></svg>''',
    'assets/images/stories/story_turtle.svg': '''<svg viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg"><rect width="200" height="140" rx="16" fill="#DCFCE7"/><ellipse cx="80" cy="85" rx="35" ry="24" fill="#15803D"/><ellipse cx="120" cy="85" rx="14" ry="10" fill="#86EFAC"/><circle cx="124" cy="82" r="2.5" fill="#1F2937"/></svg>''',
    'assets/images/stories/story_magic_tree.svg': '''<svg viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg"><rect width="200" height="140" rx="16" fill="#F3E8FF"/><path d="M 90 120 L 95 70 L 105 70 L 110 120 Z" fill="#78350F"/><circle cx="100" cy="55" r="40" fill="#A855F7" opacity="0.8"/><circle cx="95" cy="45" r="3" fill="#FDE047"/></svg>''',

    // Flags
    'assets/images/flags/flag_uk.svg': '''<svg viewBox="0 0 60 40" xmlns="http://www.w3.org/2000/svg"><rect width="60" height="40" fill="#012169"/><path d="M0,0 L60,40 M60,0 L0,40" stroke="#FFFFFF" stroke-width="6"/><path d="M0,0 L60,40 M60,0 L0,40" stroke="#C8102E" stroke-width="4"/><path d="M30,0 L30,40 M0,20 L60,20" stroke="#FFFFFF" stroke-width="10"/><path d="M30,0 L30,40 M0,20 L60,20" stroke="#C8102E" stroke-width="6"/></svg>''',
    'assets/images/flags/flag_telugu.svg': '''<svg viewBox="0 0 60 40" xmlns="http://www.w3.org/2000/svg"><rect width="60" height="13.3" fill="#FF9933"/><rect y="13.3" width="60" height="13.4" fill="#FFFFFF"/><rect y="26.7" width="60" height="13.3" fill="#138808"/><circle cx="30" cy="20" r="5" stroke="#000080" stroke-width="1" fill="none"/></svg>''',
    'assets/images/flags/flag_hindi.svg': '''<svg viewBox="0 0 60 40" xmlns="http://www.w3.org/2000/svg"><rect width="60" height="13.3" fill="#FF9933"/><rect y="13.3" width="60" height="13.4" fill="#FFFFFF"/><rect y="26.7" width="60" height="13.3" fill="#138808"/><circle cx="30" cy="20" r="5" stroke="#000080" stroke-width="1" fill="none"/></svg>''',

    // Badges
    'assets/images/badges/badge_first_lesson.svg': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="44" fill="#FEF3C7" stroke="#F59E0B" stroke-width="4"/><polygon points="50,22 58,38 76,38 61,49 67,66 50,56 33,66 39,49 24,38 42,38" fill="#F59E0B"/></svg>''',
    'assets/images/badges/badge_quiz_master.svg': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="44" fill="#E0F2FE" stroke="#0284C7" stroke-width="4"/><polygon points="50,22 58,38 76,38 61,49 67,66 50,56 33,66 39,49 24,38 42,38" fill="#0284C7"/></svg>''',
    'assets/images/badges/badge_streak.svg': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="44" fill="#FFEDD5" stroke="#EA580C" stroke-width="4"/><path d="M 50 20 C 55 35 70 45 70 60 C 70 75 60 82 50 82 C 40 82 30 75 30 60 C 30 45 45 35 50 20 Z" fill="#F97316"/></svg>''',
    'assets/images/badges/badge_locked.svg': '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="44" fill="#F1F5F9" stroke="#CBD5E1" stroke-width="4"/><path d="M 38 48 L 38 38 C 38 30 62 30 62 38 L 62 48" stroke="#94A3B8" stroke-width="6" fill="none"/><rect x="32" y="48" width="36" height="28" rx="6" fill="#94A3B8"/></svg>''',
  };

  print('Generating ${assets.length} SVG assets...');
  for (final entry in assets.entries) {
    final file = File(entry.key);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
    print('Wrote: ${entry.key}');
  }
  print('Asset generation complete!');
}
