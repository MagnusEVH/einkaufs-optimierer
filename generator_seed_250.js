// generator_seed_250.js
// Generates the comprehensive 250-item grocery catalog and SQL seed file

const fs = require('fs');
const path = require('path');

const categories = [
  { id: '11111111-0000-0000-0000-000000000001', name: 'Obst & Gemüse', icon: 'apple' },
  { id: '11111111-0000-0000-0000-000000000002', name: 'Molkerei & Eier', icon: 'egg' },
  { id: '11111111-0000-0000-0000-000000000003', name: 'Brot & Backwaren', icon: 'bread' },
  { id: '11111111-0000-0000-0000-000000000004', name: 'Fleisch, Fisch & Veggie', icon: 'food_bank' },
  { id: '11111111-0000-0000-0000-000000000005', name: 'Vorrat & Teigwaren', icon: 'rice_bowl' },
  { id: '11111111-0000-0000-0000-000000000006', name: 'Süßes & Snacks', icon: 'cookie' },
  { id: '11111111-0000-0000-0000-000000000007', name: 'Getränke & Kaffee', icon: 'local_cafe' },
  { id: '11111111-0000-0000-0000-000000000008', name: 'Drogerie & Haushalt', icon: 'clean_hands' },
];

// Product master list: exactly 250 everyday staples
const rawProductTemplates = [
  // --- 1. OBST & GEMÜSE (35 Artikel) ---
  { cat: 0, name: 'Bananen', brand: 'Fairtrade', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['banane', 'bananen'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 0, name: 'Bio Bananen', brand: '', amount: 1.0, unit: 'kg', bio: true, pl: true, aliases: ['bio banane', 'bananen bio'], pLidl: 189, pAldi: 179, pRewe: 199 }, // Aldi cheaper
  { cat: 0, name: 'Äpfel Gala', brand: '', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['apfel', 'äpfel', 'gala'], pLidl: 199, pAldi: 199, pRewe: 229 },
  { cat: 0, name: 'Bio Äpfel Topaz', brand: '', amount: 1.0, unit: 'kg', bio: true, pl: true, aliases: ['bio äpfel', 'bio apfel'], pLidl: 269, pAldi: 249, pRewe: 299 }, // Aldi cheaper
  { cat: 0, name: 'Gurke', brand: '', amount: 1.0, unit: 'piece', bio: false, pl: true, aliases: ['salatgurke', 'gurke'], pLidl: 79, pAldi: 79, pRewe: 89 },
  { cat: 0, name: 'Bio Gurke', brand: '', amount: 1.0, unit: 'piece', bio: true, pl: true, aliases: ['bio gurke'], pLidl: 119, pAldi: 109, pRewe: 129 }, // Aldi cheaper
  { cat: 0, name: 'Rispentomaten', brand: '', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['tomate', 'tomaten', 'rispentomate'], pLidl: 219, pAldi: 219, pRewe: 249 },
  { cat: 0, name: 'Cherrytomaten 250g', brand: '', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['cherrytomaten', 'kirschtomaten'], pLidl: 99, pAldi: 99, pRewe: 119 },
  { cat: 0, name: 'Bio Cherrytomaten 250g', brand: '', amount: 250, unit: 'g', bio: true, pl: true, aliases: ['bio tomaten', 'bio cherrytomaten'], pLidl: 149, pAldi: 139, pRewe: 169 }, // Aldi cheaper
  { cat: 0, name: 'Speisekartoffeln festkochend 2,5kg', brand: '', amount: 2.5, unit: 'kg', bio: false, pl: true, aliases: ['kartoffeln', 'erdäpfel'], pLidl: 249, pAldi: 249, pRewe: 279 },
  { cat: 0, name: 'Bio Kartoffeln 1,5kg', brand: '', amount: 1.5, unit: 'kg', bio: true, pl: true, aliases: ['bio kartoffeln'], pLidl: 229, pAldi: 219, pRewe: 249 }, // Aldi cheaper
  { cat: 0, name: 'Zwiebeln gelb 1kg', brand: '', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['zwiebel', 'zwiebeln'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 0, name: 'Rote Zwiebeln 500g', brand: '', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['rote zwiebeln'], pLidl: 99, pAldi: 99, pRewe: 119 },
  { cat: 0, name: 'Möhren / Karotten 1kg', brand: '', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['möhren', 'karotten', 'rübli'], pLidl: 99, pAldi: 89, pRewe: 119 }, // Aldi cheaper
  { cat: 0, name: 'Bio Möhren 1kg', brand: '', amount: 1.0, unit: 'kg', bio: true, pl: true, aliases: ['bio möhren', 'bio karotten'], pLidl: 149, pAldi: 139, pRewe: 169 }, // Aldi cheaper
  { cat: 0, name: 'Paprika Dreierpack 500g', brand: '', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['paprika', 'paprika rot gelb grün'], pLidl: 169, pAldi: 169, pRewe: 199 },
  { cat: 0, name: 'Spitzpaprika rot 500g', brand: '', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['spitzpaprika'], pLidl: 179, pAldi: 169, pRewe: 199 }, // Aldi cheaper
  { cat: 0, name: 'Eisbergsalat', brand: '', amount: 1.0, unit: 'piece', bio: false, pl: true, aliases: ['salat', 'eisbergsalat'], pLidl: 99, pAldi: 99, pRewe: 119 },
  { cat: 0, name: 'Kopfsalat', brand: '', amount: 1.0, unit: 'piece', bio: false, pl: true, aliases: ['kopfsalat'], pLidl: 89, pAldi: 79, pRewe: 99 }, // Aldi cheaper
  { cat: 0, name: 'Rucola 125g', brand: '', amount: 125, unit: 'g', bio: false, pl: true, aliases: ['rucola', 'rauhe rauke'], pLidl: 89, pAldi: 89, pRewe: 99 },
  { cat: 0, name: 'Babyspinat 125g', brand: '', amount: 125, unit: 'g', bio: false, pl: true, aliases: ['spinat', 'babyspinat'], pLidl: 119, pAldi: 119, pRewe: 139 },
  { cat: 0, name: 'Zucchini 1kg', brand: '', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['zucchini'], pLidl: 189, pAldi: 179, pRewe: 219 }, // Aldi cheaper
  { cat: 0, name: 'Auberginen 1kg', brand: '', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['aubergine'], pLidl: 199, pAldi: 189, pRewe: 229 },
  { cat: 0, name: 'Brokkoli 500g', brand: '', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['brokkoli', 'broccoli'], pLidl: 129, pAldi: 129, pRewe: 149 },
  { cat: 0, name: 'Blumenkohl', brand: '', amount: 1.0, unit: 'piece', bio: false, pl: true, aliases: ['blumenkohl'], pLidl: 199, pAldi: 189, pRewe: 249 },
  { cat: 0, name: 'Champignons braun 400g', brand: '', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['pilze', 'champignons', 'braune champignons'], pLidl: 169, pAldi: 159, pRewe: 189 }, // Aldi cheaper
  { cat: 0, name: 'Champignons weiß 400g', brand: '', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['weiße champignons'], pLidl: 149, pAldi: 149, pRewe: 169 },
  { cat: 0, name: 'Avocado Hass genussreif', brand: '', amount: 1.0, unit: 'piece', bio: false, pl: true, aliases: ['avocado'], pLidl: 119, pAldi: 109, pRewe: 149 },
  { cat: 0, name: 'Bio Avocado 2er Pack', brand: '', amount: 2.0, unit: 'piece', bio: true, pl: true, aliases: ['bio avocado'], pLidl: 249, pAldi: 229, pRewe: 299 }, // Aldi cheaper
  { cat: 0, name: 'Heidelbeeren 300g', brand: '', amount: 300, unit: 'g', bio: false, pl: true, aliases: ['blaubeeren', 'heidelbeeren'], pLidl: 299, pAldi: 289, pRewe: 349 },
  { cat: 0, name: 'Erdbeeren 500g', brand: '', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['erdbeeren'], pLidl: 249, pAldi: 249, pRewe: 279 },
  { cat: 0, name: 'Zitronen Netz 500g', brand: '', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['zitrone', 'zitronen'], pLidl: 119, pAldi: 109, pRewe: 129 },
  { cat: 0, name: 'Bio Zitronen 500g', brand: '', amount: 500, unit: 'g', bio: true, pl: true, aliases: ['bio zitrone', 'bio zitronen'], pLidl: 149, pAldi: 139, pRewe: 169 },
  { cat: 0, name: 'Knoblauch 200g', brand: '', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['knoblauch'], pLidl: 89, pAldi: 79, pRewe: 99 },
  { cat: 0, name: 'Ingwer 250g', brand: '', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['ingwer'], pLidl: 99, pAldi: 89, pRewe: 129 },

  // --- 2. MOLKEREI & EIER (45 Artikel) ---
  { cat: 1, name: 'Skyr Natur 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['skyr', 'skyr natur'], pLidl: 119, pAldi: 129, pRewe: 139 }, // Lidl cheaper
  { cat: 1, name: 'Skyr Vanille 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['skyr vanille'], pLidl: 129, pAldi: 139, pRewe: 149 }, // Lidl cheaper
  { cat: 1, name: 'Ísey Skyr Erdbeere 170g', brand: 'Ísey', amount: 170, unit: 'g', bio: false, pl: false, aliases: ['isey skyr'], pLidl: 129, pAldi: 139, pRewe: 119 }, // Rewe on sale!
  { cat: 1, name: 'Frische Vollmilch 3,5% 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['vollmilch', 'milch 3.5', 'milch'], pLidl: 95, pAldi: 95, pRewe: 99 },
  { cat: 1, name: 'H-Vollmilch 3,5% 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['h milch 3.5', 'h-milch'], pLidl: 95, pAldi: 95, pRewe: 99 },
  { cat: 1, name: 'Frische fettarme Milch 1,5% 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['milch 1.5', 'fettarme milch'], pLidl: 95, pAldi: 95, pRewe: 99 },
  { cat: 1, name: 'H-Milch fettarm 1,5% 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['h milch 1.5'], pLidl: 95, pAldi: 95, pRewe: 99 },
  { cat: 1, name: 'Bio Frische Milch 3,8% 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: true, pl: true, aliases: ['bio milch', 'bio vollmilch'], pLidl: 139, pAldi: 129, pRewe: 149 }, // Aldi cheaper
  { cat: 1, name: 'Bärenmarke Frische Alpenmilch 3,8% 1L', brand: 'Bärenmarke', amount: 1.0, unit: 'l', bio: false, pl: false, aliases: ['bärenmarke milch'], pLidl: 179, pAldi: 179, pRewe: 169 }, // Rewe on offer
  { cat: 1, name: 'Deutsche Markenbutter 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['butter', 'markenbutter'], pLidl: 169, pAldi: 159, pRewe: 179 }, // Aldi cheaper
  { cat: 1, name: 'Bio Süßrahmbutter 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: true, pl: true, aliases: ['bio butter'], pLidl: 249, pAldi: 239, pRewe: 259 },
  { cat: 1, name: 'Kerrygold Irische Butter 250g', brand: 'Kerrygold', amount: 250, unit: 'g', bio: false, pl: false, aliases: ['kerrygold', 'irische butter'], pLidl: 239, pAldi: 259, pRewe: 279 }, // Lidl offer!
  { cat: 1, name: 'Magerquark 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['magerquark', 'quark'], pLidl: 135, pAldi: 135, pRewe: 139 },
  { cat: 1, name: 'Speisequark 20% 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['speisequark', 'quark 20%'], pLidl: 145, pAldi: 145, pRewe: 149 },
  { cat: 1, name: 'Bio Magerquark 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: true, pl: true, aliases: ['bio magerquark', 'bio quark'], pLidl: 179, pAldi: 179, pRewe: 189 },
  { cat: 1, name: 'Naturjoghurt 3,5% 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['joghurt natur', 'naturjoghurt'], pLidl: 85, pAldi: 85, pRewe: 89 },
  { cat: 1, name: 'Griechischer Joghurt 10% 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['griechischer joghurt', 'joghurt 10%'], pLidl: 169, pAldi: 169, pRewe: 179 },
  { cat: 1, name: 'Ehrmann Grand Dessert Schoko 190g', brand: 'Ehrmann', amount: 190, unit: 'g', bio: false, pl: false, aliases: ['grand dessert', 'schokopudding'], pLidl: 89, pAldi: 89, pRewe: 89 },
  { cat: 1, name: 'Schmand 24% 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['schmand'], pLidl: 89, pAldi: 89, pRewe: 99 },
  { cat: 1, name: 'Saure Sahne 10% 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['saure sahne'], pLidl: 79, pAldi: 79, pRewe: 89 },
  { cat: 1, name: 'Schlagsahne 30% 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['sahne', 'schlagsahne'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 1, name: 'Crème Fraîche 150g', brand: 'Eigenmarke', amount: 150, unit: 'g', bio: false, pl: true, aliases: ['creme fraiche'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 1, name: 'Gouda jung in Scheiben 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['gouda', 'käse scheiben'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 1, name: 'Gouda mittelalt 300g', brand: 'Eigenmarke', amount: 300, unit: 'g', bio: false, pl: true, aliases: ['gouda mittelalt'], pLidl: 229, pAldi: 229, pRewe: 249 },
  { cat: 1, name: 'Butterkäse Scheiben 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['butterkäse'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 1, name: 'Emmentaler gerieben 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['reibekäse', 'emmentaler'], pLidl: 169, pAldi: 169, pRewe: 189 },
  { cat: 1, name: 'Gouda gerieben 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['gouda gerieben', 'streukäse'], pLidl: 169, pAldi: 169, pRewe: 179 },
  { cat: 1, name: 'Mozzarella Kugel 125g', brand: 'Eigenmarke', amount: 125, unit: 'g', bio: false, pl: true, aliases: ['mozzarella'], pLidl: 85, pAldi: 85, pRewe: 89 },
  { cat: 1, name: 'Bio Mozzarella 125g', brand: 'Eigenmarke', amount: 125, unit: 'g', bio: true, pl: true, aliases: ['bio mozzarella'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 1, name: 'Galbani Mozzarella 125g', brand: 'Galbani', amount: 125, unit: 'g', bio: false, pl: false, aliases: ['galbani mozzarella'], pLidl: 159, pAldi: 169, pRewe: 159 },
  { cat: 1, name: 'Hirtenkäse / Weichkäse 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['hirtenkäse', 'weichkäse'], pLidl: 179, pAldi: 179, pRewe: 199 },
  { cat: 1, name: 'Original Griechischer Feta 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['feta', 'schafskäse'], pLidl: 229, pAldi: 229, pRewe: 249 },
  { cat: 1, name: 'Frischkäse Doppelrahm 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['frischkäse'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 1, name: 'Philadelphia Original 175g', brand: 'Philadelphia', amount: 175, unit: 'g', bio: false, pl: false, aliases: ['philadelphia'], pLidl: 169, pAldi: 169, pRewe: 169 },
  { cat: 1, name: 'Camembert 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['camembert'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 1, name: 'Parmigiano Reggiano 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['parmesan', 'parmigiano'], pLidl: 349, pAldi: 349, pRewe: 379 },
  { cat: 1, name: 'Frische Eier Bodenhaltung Gr. M/L 10er', brand: 'Eigenmarke', amount: 10, unit: 'piece', bio: false, pl: true, aliases: ['eier', '10 eier', 'hühnereier'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 1, name: 'Freilandeier Gr. M/L 10er', brand: 'Eigenmarke', amount: 10, unit: 'piece', bio: false, pl: true, aliases: ['freilandeier'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 1, name: 'Bio Eier 10er', brand: 'Eigenmarke', amount: 10, unit: 'piece', bio: true, pl: true, aliases: ['bio eier'], pLidl: 329, pAldi: 329, pRewe: 349 },
  { cat: 1, name: 'Oatly Hafermilch Barista 1L', brand: 'Oatly', amount: 1.0, unit: 'l', bio: false, pl: false, aliases: ['oatly', 'hafermilch barista'], pLidl: 219, pAldi: 219, pRewe: 229 },
  { cat: 1, name: 'Bio Haferdrink Natur 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: true, pl: true, aliases: ['hafermilch', 'haferdrink'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 1, name: 'Bio Sojadrink Natur 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: true, pl: true, aliases: ['sojamilch', 'sojadrink'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 1, name: 'Müller Milchreis Zimt 200g', brand: 'Müller', amount: 200, unit: 'g', bio: false, pl: false, aliases: ['milchreis', 'müller milchreis'], pLidl: 69, pAldi: 79, pRewe: 79 },
  { cat: 1, name: 'Zott Sahnejoghurt Erdbeer 150g', brand: 'Zott', amount: 150, unit: 'g', bio: false, pl: false, aliases: ['zott joghurt', 'sahnejoghurt'], pLidl: 79, pAldi: 79, pRewe: 79 },
  { cat: 1, name: 'Activia Natur 4x115g', brand: 'Danone', amount: 460, unit: 'g', bio: false, pl: false, aliases: ['activia'], pLidl: 219, pAldi: 229, pRewe: 229 },

  // --- 3. BROT & BACKWAREN (25 Artikel) ---
  { cat: 2, name: 'Butter Toastbrot 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['toast', 'toastbrot', 'buttertoast'], pLidl: 89, pAldi: 89, pRewe: 99 },
  { cat: 2, name: 'Vollkorn Toastbrot 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['vollkorntoast'], pLidl: 89, pAldi: 89, pRewe: 99 },
  { cat: 2, name: 'Golden Toast Butter 500g', brand: 'Golden Toast', amount: 500, unit: 'g', bio: false, pl: false, aliases: ['golden toast'], pLidl: 169, pAldi: 169, pRewe: 179 },
  { cat: 2, name: 'Weizenmischbrot geschnitten 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['brot', 'mischbrot', 'weizenbrot'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 2, name: 'Vollkornbrot geschnitten 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['vollkornbrot'], pLidl: 129, pAldi: 129, pRewe: 139 },
  { cat: 2, name: 'Paderborner Landbrot 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['landbrot', 'graubrot'], pLidl: 169, pAldi: 169, pRewe: 189 },
  { cat: 2, name: 'Sonnenblumenkernbrot 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['sonnenblumenbrot'], pLidl: 139, pAldi: 139, pRewe: 149 },
  { cat: 2, name: 'Baguette zum Aufbacken 2x150g', brand: 'Eigenmarke', amount: 300, unit: 'g', bio: false, pl: true, aliases: ['baguette', 'aufbackbaguette'], pLidl: 89, pAldi: 89, pRewe: 99 },
  { cat: 2, name: 'Kräuterbutter Baguette 175g', brand: 'Eigenmarke', amount: 175, unit: 'g', bio: false, pl: true, aliases: ['kräuterbaguette', 'knoblauchbaguette'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 2, name: 'Weizenbrötchen zum Fertigbacken 6er', brand: 'Eigenmarke', amount: 300, unit: 'g', bio: false, pl: true, aliases: ['brötchen', 'aufbackbrötchen', 'semmeln'], pLidl: 69, pAldi: 69, pRewe: 79 },
  { cat: 2, name: 'Mehrkornbrötchen 4er', brand: 'Eigenmarke', amount: 260, unit: 'g', bio: false, pl: true, aliases: ['körnerbrötchen', 'mehrkornbrötchen'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 2, name: 'Knäckebrot Roggen 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['knäckebrot'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 2, name: 'Wasa Knäckebrot Sesam 200g', brand: 'Wasa', amount: 200, unit: 'g', bio: false, pl: false, aliases: ['wasa'], pLidl: 179, pAldi: 189, pRewe: 189 },
  { cat: 2, name: 'Tortilla Wraps Weizen 6er 370g', brand: 'Eigenmarke', amount: 370, unit: 'g', bio: false, pl: true, aliases: ['wraps', 'tortillas'], pLidl: 129, pAldi: 129, pRewe: 139 },
  { cat: 2, name: 'Pizzaboden mit Tomatensauce 600g', brand: 'Eigenmarke', amount: 600, unit: 'g', bio: false, pl: true, aliases: ['pizzateig', 'frischer pizzateig'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 2, name: 'Haferflocken zart 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['haferflocken', 'haferflocken zart'], pLidl: 79, pAldi: 79, pRewe: 85 },
  { cat: 2, name: 'Haferflocken kernig 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['haferflocken kernig'], pLidl: 79, pAldi: 79, pRewe: 85 },
  { cat: 2, name: 'Bio Haferflocken 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: true, pl: true, aliases: ['bio haferflocken'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 2, name: 'Kölln Flocken Blütenzart 500g', brand: 'Kölln', amount: 500, unit: 'g', bio: false, pl: false, aliases: ['kölln flocken'], pLidl: 189, pAldi: 199, pRewe: 199 },
  { cat: 2, name: 'Weizenmehl Type 405 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['mehl', 'weizenmehl', 'mehl 405'], pLidl: 65, pAldi: 65, pRewe: 69 },
  { cat: 2, name: 'Bio Dinkelmehl Type 630 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: true, pl: true, aliases: ['dinkelmehl', 'bio mehl'], pLidl: 169, pAldi: 169, pRewe: 189 },
  { cat: 2, name: 'Weißer Haushaltszucker 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['zucker', 'kristallzucker'], pLidl: 119, pAldi: 119, pRewe: 125 },
  { cat: 2, name: 'Puderzucker 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['puderzucker'], pLidl: 49, pAldi: 49, pRewe: 55 },
  { cat: 2, name: 'Backpulver 10er Pack', brand: 'Eigenmarke', amount: 150, unit: 'g', bio: false, pl: true, aliases: ['backpulver'], pLidl: 45, pAldi: 45, pRewe: 49 },
  { cat: 2, name: 'Frische Backhefe 42g', brand: 'Eigenmarke', amount: 42, unit: 'g', bio: false, pl: true, aliases: ['hefe', 'frische hefe'], pLidl: 19, pAldi: 19, pRewe: 25 },

  // --- 4. FLEISCH, FISCH & VEGGIE (30 Artikel) ---
  { cat: 3, name: 'Hackfleisch gemischt (Rind & Schwein) 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['hackfleisch', 'hack', 'gemischtes hack'], pLidl: 399, pAldi: 399, pRewe: 429 },
  { cat: 3, name: 'Rinderhackfleisch 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['rinderhack'], pLidl: 449, pAldi: 449, pRewe: 479 },
  { cat: 3, name: 'Bio Rinderhackfleisch 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: true, pl: true, aliases: ['bio hackfleisch', 'bio rinderhack'], pLidl: 549, pAldi: 549, pRewe: 599 },
  { cat: 3, name: 'Hähnchenbrustfilet 600g', brand: 'Eigenmarke', amount: 600, unit: 'g', bio: false, pl: true, aliases: ['hähnchenbrust', 'hähnchen', 'hühnchen'], pLidl: 599, pAldi: 599, pRewe: 649 },
  { cat: 3, name: 'Hähnchen-Innenfilet 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['hähnchenfilet'], pLidl: 429, pAldi: 429, pRewe: 469 },
  { cat: 3, name: 'Bio Hähnchenbrust 300g', brand: 'Eigenmarke', amount: 300, unit: 'g', bio: true, pl: true, aliases: ['bio hähnchen'], pLidl: 699, pAldi: 699, pRewe: 749 },
  { cat: 3, name: 'Putenschnitzel 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['putenschnitzel', 'pute'], pLidl: 499, pAldi: 499, pRewe: 549 },
  { cat: 3, name: 'Rostbratwurst 5er 450g', brand: 'Eigenmarke', amount: 450, unit: 'g', bio: false, pl: true, aliases: ['bratwurst'], pLidl: 299, pAldi: 299, pRewe: 329 },
  { cat: 3, name: 'Wiener Würstchen 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['wiener', 'würstchen'], pLidl: 299, pAldi: 299, pRewe: 329 },
  { cat: 3, name: 'Kochschinken geschnitten 150g', brand: 'Eigenmarke', amount: 150, unit: 'g', bio: false, pl: true, aliases: ['kochschinken', 'schinken'], pLidl: 169, pAldi: 169, pRewe: 189 },
  { cat: 3, name: 'Geflügel-Mortadella 150g', brand: 'Eigenmarke', amount: 150, unit: 'g', bio: false, pl: true, aliases: ['mortadella', 'geflügelwurst'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 3, name: 'Salami 1A 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['salami'], pLidl: 179, pAldi: 179, pRewe: 199 },
  { cat: 3, name: 'Lachsschinken 100g', brand: 'Eigenmarke', amount: 100, unit: 'g', bio: false, pl: true, aliases: ['lachsschinken'], pLidl: 169, pAldi: 169, pRewe: 189 },
  { cat: 3, name: 'Bacon / Frühstücksspeck 100g', brand: 'Eigenmarke', amount: 100, unit: 'g', bio: false, pl: true, aliases: ['bacon', 'speck'], pLidl: 129, pAldi: 129, pRewe: 149 },
  { cat: 3, name: 'Schinkenwürfel 2x125g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['schinkenwürfel'], pLidl: 189, pAldi: 189, pRewe: 199 },
  { cat: 3, name: 'Lachsfilet frisch mit Haut 300g', brand: 'Eigenmarke', amount: 300, unit: 'g', bio: false, pl: true, aliases: ['lachs', 'lachsfilet'], pLidl: 599, pAldi: 599, pRewe: 649 },
  { cat: 3, name: 'Räucherlachs 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['räucherlachs'], pLidl: 399, pAldi: 399, pRewe: 429 },
  { cat: 3, name: 'Thunfisch in eigenem Saft 185g', brand: 'Eigenmarke', amount: 185, unit: 'g', bio: false, pl: true, aliases: ['thunfisch', 'dose thunfisch'], pLidl: 139, pAldi: 139, pRewe: 149 },
  { cat: 3, name: 'Thunfisch in Sonnenblumenöl 185g', brand: 'Eigenmarke', amount: 185, unit: 'g', bio: false, pl: true, aliases: ['thunfisch öl'], pLidl: 139, pAldi: 139, pRewe: 149 },
  { cat: 3, name: 'Iglo Fischstäbchen 15er 450g', brand: 'Iglo', amount: 450, unit: 'g', bio: false, pl: false, aliases: ['fischstäbchen', 'iglo fischstäbchen'], pLidl: 389, pAldi: 399, pRewe: 389 },
  { cat: 3, name: 'Fischstäbchen 15er 450g', brand: 'Eigenmarke', amount: 450, unit: 'g', bio: false, pl: true, aliases: ['fischstäbchen günstig'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 3, name: 'Tofu Natur Bio 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: true, pl: true, aliases: ['tofu', 'bio tofu'], pLidl: 179, pAldi: 179, pRewe: 199 },
  { cat: 3, name: 'Räuchertofu Bio 350g', brand: 'Eigenmarke', amount: 350, unit: 'g', bio: true, pl: true, aliases: ['räuchertofu'], pLidl: 189, pAldi: 189, pRewe: 209 },
  { cat: 3, name: 'Vegane Mühlen Salami 80g', brand: 'Rügenwalder Mühle', amount: 80, unit: 'g', bio: false, pl: false, aliases: ['vegane salami', 'mühlen salami'], pLidl: 149, pAldi: 149, pRewe: 149 },
  { cat: 3, name: 'Vegane Mühlen Bratwurst 180g', brand: 'Rügenwalder Mühle', amount: 180, unit: 'g', bio: false, pl: false, aliases: ['vegane bratwurst'], pLidl: 269, pAldi: 279, pRewe: 269 },
  { cat: 3, name: 'Veganes Hack 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['veganes hack', 'veggie hack'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 3, name: 'Vegane Burger Patties 227g', brand: 'Eigenmarke', amount: 227, unit: 'g', bio: false, pl: true, aliases: ['veggie burger', 'veganer burger'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 3, name: 'Vegane Nuggets 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['vegane nuggets'], pLidl: 179, pAldi: 179, pRewe: 199 },
  { cat: 3, name: 'Falafel Bällchen 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['falafel'], pLidl: 169, pAldi: 169, pRewe: 189 },
  { cat: 3, name: 'Hummus Natur 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['hummus'], pLidl: 119, pAldi: 119, pRewe: 129 },

  // --- 5. VORRAT & TEIGWAREN (45 Artikel) ---
  { cat: 4, name: 'Spaghetti No. 5 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['spaghetti', 'nudeln'], pLidl: 79, pAldi: 79, pRewe: 85 },
  { cat: 4, name: 'Penne Rigate 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['penne', 'röhrennudeln'], pLidl: 79, pAldi: 79, pRewe: 85 },
  { cat: 4, name: 'Fusilli 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['fusilli', 'spirelli'], pLidl: 79, pAldi: 79, pRewe: 85 },
  { cat: 4, name: 'Bio Vollkorn Spaghetti 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: true, pl: true, aliases: ['vollkornnudeln', 'bio spaghetti'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 4, name: 'Barilla Spaghetti No. 5 500g', brand: 'Barilla', amount: 500, unit: 'g', bio: false, pl: false, aliases: ['barilla spaghetti', 'barilla'], pLidl: 189, pAldi: 189, pRewe: 149 }, // Rewe on promotion!
  { cat: 4, name: 'Barilla Penne Rigate 500g', brand: 'Barilla', amount: 500, unit: 'g', bio: false, pl: false, aliases: ['barilla penne'], pLidl: 189, pAldi: 189, pRewe: 149 }, // Rewe on promotion!
  { cat: 4, name: 'Basmati Reis 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['reis', 'basmati', 'basmatireis'], pLidl: 199, pAldi: 189, pRewe: 219 }, // Aldi cheaper
  { cat: 4, name: 'Jasmin Duftreis 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['jasminreis'], pLidl: 199, pAldi: 189, pRewe: 219 }, // Aldi cheaper
  { cat: 4, name: 'Parboiled Spitzenlangkornreis 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['langkornreis', 'parboiled reis'], pLidl: 149, pAldi: 139, pRewe: 169 },
  { cat: 4, name: 'Passierte Tomaten 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['passierte tomaten', 'passata'], pLidl: 65, pAldi: 65, pRewe: 69 },
  { cat: 4, name: 'Gehackte Tomaten Dose 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['gehackte tomaten', 'dosentomaten', 'stückige tomaten'], pLidl: 65, pAldi: 65, pRewe: 69 },
  { cat: 4, name: 'Mutti Polpa stückige Tomaten 400g', brand: 'Mutti', amount: 400, unit: 'g', bio: false, pl: false, aliases: ['mutti tomaten', 'mutti polpa'], pLidl: 149, pAldi: 149, pRewe: 139 }, // Rewe cheaper
  { cat: 4, name: 'Tomatenmark dreifach konzentriert 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['tomatenmark'], pLidl: 85, pAldi: 85, pRewe: 89 },
  { cat: 4, name: 'Pesto Genovese grün 190g', brand: 'Eigenmarke', amount: 190, unit: 'g', bio: false, pl: true, aliases: ['pesto', 'grünes pesto', 'pesto genovese'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 4, name: 'Pesto Rosso rot 190g', brand: 'Eigenmarke', amount: 190, unit: 'g', bio: false, pl: true, aliases: ['rotes pesto', 'pesto rosso'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 4, name: 'Barilla Pesto Alla Genovese 190g', brand: 'Barilla', amount: 190, unit: 'g', bio: false, pl: false, aliases: ['barilla pesto'], pLidl: 329, pAldi: 329, pRewe: 279 }, // Rewe offer!
  { cat: 4, name: 'Kidneybohnen Dose 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['kidneybohnen', 'bohnen'], pLidl: 69, pAldi: 69, pRewe: 75 },
  { cat: 4, name: 'Kichererbsen Dose 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['kichererbsen'], pLidl: 69, pAldi: 69, pRewe: 75 },
  { cat: 4, name: 'Mais süß Dose 330g', brand: 'Eigenmarke', amount: 330, unit: 'g', bio: false, pl: true, aliases: ['mais', 'dosenmais'], pLidl: 85, pAldi: 85, pRewe: 89 },
  { cat: 4, name: 'Grüne Erbsen mit Möhren 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['erbsen möhren'], pLidl: 89, pAldi: 89, pRewe: 99 },
  { cat: 4, name: 'Natives Olivenöl Extra 750ml', brand: 'Eigenmarke', amount: 750, unit: 'ml', bio: false, pl: true, aliases: ['olivenöl', 'natives olivenöl'], pLidl: 799, pAldi: 799, pRewe: 849 },
  { cat: 4, name: 'Bio Olivenöl Extra 500ml', brand: 'Eigenmarke', amount: 500, unit: 'ml', bio: true, pl: true, aliases: ['bio olivenöl'], pLidl: 649, pAldi: 649, pRewe: 699 },
  { cat: 4, name: 'Rapsöl raffiniert 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['rapsöl', 'speiseöl'], pLidl: 159, pAldi: 149, pRewe: 169 }, // Aldi cheaper
  { cat: 4, name: 'Sonnenblumenöl 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['sonnenblumenöl'], pLidl: 169, pAldi: 159, pRewe: 179 }, // Aldi cheaper
  { cat: 4, name: 'Balsamico Essig di Modena 500ml', brand: 'Eigenmarke', amount: 500, unit: 'ml', bio: false, pl: true, aliases: ['essig', 'balsamico'], pLidl: 149, pAldi: 149, pRewe: 169 },
  { cat: 4, name: 'Apfelessig 750ml', brand: 'Eigenmarke', amount: 750, unit: 'ml', bio: false, pl: true, aliases: ['apfelessig'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 4, name: 'Jodsalz mit Fluorid 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['salz', 'speisesalz', 'jodsalz'], pLidl: 29, pAldi: 29, pRewe: 35 },
  { cat: 4, name: 'Schwarzer Pfeffer gemahlen 50g', brand: 'Eigenmarke', amount: 50, unit: 'g', bio: false, pl: true, aliases: ['pfeffer', 'schwarzer pfeffer'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 4, name: 'Paprikapulver edelsüß 50g', brand: 'Eigenmarke', amount: 50, unit: 'g', bio: false, pl: true, aliases: ['paprikapulver'], pLidl: 79, pAldi: 79, pRewe: 89 },
  { cat: 4, name: 'Gemüsebrühe Glas 140g', brand: 'Eigenmarke', amount: 140, unit: 'g', bio: false, pl: true, aliases: ['brühe', 'gemüsebrühe'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 4, name: 'Mittelscharfer Senf 200ml', brand: 'Eigenmarke', amount: 200, unit: 'ml', bio: false, pl: true, aliases: ['senf'], pLidl: 55, pAldi: 55, pRewe: 59 },
  { cat: 4, name: 'Bautz’ner Senf mittelscharf 200ml', brand: 'Bautzner', amount: 200, unit: 'ml', bio: false, pl: false, aliases: ['bautzner senf'], pLidl: 69, pAldi: 69, pRewe: 69 },
  { cat: 4, name: 'Tomaten Ketchup 500ml', brand: 'Eigenmarke', amount: 500, unit: 'ml', bio: false, pl: true, aliases: ['ketchup'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 4, name: 'Heinz Tomato Ketchup 500ml', brand: 'Heinz', amount: 500, unit: 'ml', bio: false, pl: false, aliases: ['heinz ketchup'], pLidl: 299, pAldi: 299, pRewe: 269 }, // Rewe offer!
  { cat: 4, name: 'Delikatess Mayonnaise 500ml', brand: 'Eigenmarke', amount: 500, unit: 'ml', bio: false, pl: true, aliases: ['mayo', 'mayonnaise'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 4, name: 'Miracel Whip Original 500ml', brand: 'Miracel Whip', amount: 500, unit: 'ml', bio: false, pl: false, aliases: ['miracel whip'], pLidl: 269, pAldi: 279, pRewe: 249 }, // Rewe offer!
  { cat: 4, name: 'Blütenhonig flüssig 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['honig', 'blütenhonig'], pLidl: 279, pAldi: 279, pRewe: 299 },
  { cat: 4, name: 'Erdbeerkonfitüre Extra 450g', brand: 'Eigenmarke', amount: 450, unit: 'g', bio: false, pl: true, aliases: ['marmelade', 'erdbeermarmelade', 'konfitüre'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 4, name: 'Nutella Nuss-Nougat-Creme 450g', brand: 'Ferrero', amount: 450, unit: 'g', bio: false, pl: false, aliases: ['nutella', 'nuss nougat creme'], pLidl: 299, pAldi: 299, pRewe: 279 }, // Rewe offer!
  { cat: 4, name: 'Nuss-Nougat-Creme 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['schokocreme'], pLidl: 169, pAldi: 169, pRewe: 179 },
  { cat: 4, name: 'Erdnussbutter Creamy 350g', brand: 'Eigenmarke', amount: 350, unit: 'g', bio: false, pl: true, aliases: ['erdnussbutter', 'peanut butter'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 4, name: 'Cornflakes 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['cornflakes'], pLidl: 139, pAldi: 139, pRewe: 149 },
  { cat: 4, name: 'Früchtemüsli 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['müsli', 'früchtemüsli'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 4, name: 'Schokomüsli 750g', brand: 'Eigenmarke', amount: 750, unit: 'g', bio: false, pl: true, aliases: ['schokomüsli'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 4, name: 'Dr. Oetker Ristorante Pizza Salame 320g', brand: 'Dr. Oetker', amount: 320, unit: 'g', bio: false, pl: false, aliases: ['tiefkühlpizza', 'ristorante', 'pizza salami'], pLidl: 329, pAldi: 329, pRewe: 249 }, // Rewe big offer!

  // --- 6. SÜSSES & SNACKS (25 Artikel) ---
  { cat: 5, name: 'Vollmilchschokolade 100g', brand: 'Eigenmarke', amount: 100, unit: 'g', bio: false, pl: true, aliases: ['schokolade', 'vollmilch schokolade'], pLidl: 79, pAldi: 79, pRewe: 85 },
  { cat: 5, name: 'Zartbitterschokolade 70% 100g', brand: 'Eigenmarke', amount: 100, unit: 'g', bio: false, pl: true, aliases: ['zartbitterschokolade', 'dunkle schokolade'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 5, name: 'Milka Alpenmilch Schokolade 100g', brand: 'Milka', amount: 100, unit: 'g', bio: false, pl: false, aliases: ['milka', 'milka alpenmilch'], pLidl: 139, pAldi: 139, pRewe: 119 }, // Rewe promotion!
  { cat: 5, name: 'Ritter Sport Alpenmilch 100g', brand: 'Ritter Sport', amount: 100, unit: 'g', bio: false, pl: false, aliases: ['ritter sport'], pLidl: 149, pAldi: 149, pRewe: 119 }, // Rewe promotion!
  { cat: 5, name: 'Haribo Goldbären 175g', brand: 'Haribo', amount: 175, unit: 'g', bio: false, pl: false, aliases: ['gummibärchen', 'haribo', 'goldbären'], pLidl: 99, pAldi: 99, pRewe: 89 }, // Rewe offer!
  { cat: 5, name: 'Fruchtgummi Bären 300g', brand: 'Eigenmarke', amount: 300, unit: 'g', bio: false, pl: true, aliases: ['fruchtgummi'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 5, name: 'Kartoffelchips Paprika 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['chips', 'paprika chips'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 5, name: 'Kartoffelchips Gesalzen 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['salzchips'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 5, name: 'Funny-Frisch Chipsfrisch ungarisch 150g', brand: 'Funny-Frisch', amount: 150, unit: 'g', bio: false, pl: false, aliases: ['funny frisch', 'chipsfrisch'], pLidl: 189, pAldi: 199, pRewe: 199 },
  { cat: 5, name: 'Pringles Original 185g', brand: 'Pringles', amount: 185, unit: 'g', bio: false, pl: false, aliases: ['pringles'], pLidl: 279, pAldi: 279, pRewe: 299 },
  { cat: 5, name: 'Salzstangen 250g', brand: 'Eigenmarke', amount: 250, unit: 'g', bio: false, pl: true, aliases: ['salzstangen'], pLidl: 65, pAldi: 65, pRewe: 69 },
  { cat: 5, name: 'Erdnussflips 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['flips', 'erdnussflips'], pLidl: 89, pAldi: 89, pRewe: 95 },
  { cat: 5, name: 'Erdnüsse geröstet & gesalzen 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['erdnüsse'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 5, name: 'Studentenfutter 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['studentenfutter', 'nüsse rosinen'], pLidl: 179, pAldi: 179, pRewe: 199 },
  { cat: 5, name: 'Mandeln naturbelassen 200g', brand: 'Eigenmarke', amount: 200, unit: 'g', bio: false, pl: true, aliases: ['mandeln'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 5, name: 'Cashewkerne geröstet & gesalzen 150g', brand: 'Eigenmarke', amount: 150, unit: 'g', bio: false, pl: true, aliases: ['cashews', 'cashewkerne'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 5, name: 'Butterkeks 400g', brand: 'Eigenmarke', amount: 400, unit: 'g', bio: false, pl: true, aliases: ['kekse', 'butterkeks'], pLidl: 129, pAldi: 129, pRewe: 139 },
  { cat: 5, name: 'Leibniz Butterkeks 200g', brand: 'Leibniz', amount: 200, unit: 'g', bio: false, pl: false, aliases: ['leibniz'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 5, name: 'Doppelkeks mit Kakaocreme 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['doppelkeks', 'prinzenrolle eigenmarke'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 5, name: 'Prinzen Rolle Schoko 400g', brand: 'DeBeukelaer', amount: 400, unit: 'g', bio: false, pl: false, aliases: ['prinzen rolle'], pLidl: 189, pAldi: 189, pRewe: 199 },
  { cat: 5, name: 'Knoppers 8er 200g', brand: 'Storck', amount: 200, unit: 'g', bio: false, pl: false, aliases: ['knoppers'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 5, name: 'Hanuta 10er 220g', brand: 'Ferrero', amount: 220, unit: 'g', bio: false, pl: false, aliases: ['hanuta'], pLidl: 229, pAldi: 229, pRewe: 249 },
  { cat: 5, name: 'Duplo 10er 182g', brand: 'Ferrero', amount: 182, unit: 'g', bio: false, pl: false, aliases: ['duplo'], pLidl: 219, pAldi: 219, pRewe: 239 },
  { cat: 5, name: 'Kinder Riegel 10er 210g', brand: 'Ferrero', amount: 210, unit: 'g', bio: false, pl: false, aliases: ['kinder riegel', 'schokoriegel'], pLidl: 229, pAldi: 229, pRewe: 249 },
  { cat: 5, name: 'M&Ms Peanut 220g', brand: 'Mars', amount: 220, unit: 'g', bio: false, pl: false, aliases: ['m&ms', 'schokolinsen'], pLidl: 269, pAldi: 269, pRewe: 289 },

  // --- 7. GETRÄNKE & KAFFEE (35 Artikel) ---
  { cat: 6, name: 'Mineralwasser Medium 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['wasser medium', 'sprudelwasser', 'mineralwasser'], pLidl: 29, pAldi: 29, pRewe: 29 },
  { cat: 6, name: 'Mineralwasser Still 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['stilles wasser', 'wasser still'], pLidl: 29, pAldi: 29, pRewe: 29 },
  { cat: 6, name: 'Mineralwasser Classic mit Sprudel 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['sprudel classic'], pLidl: 29, pAldi: 29, pRewe: 29 },
  { cat: 6, name: 'Gerolsteiner Medium 1L', brand: 'Gerolsteiner', amount: 1.0, unit: 'l', bio: false, pl: false, aliases: ['gerolsteiner'], pLidl: 79, pAldi: 79, pRewe: 85 },
  { cat: 6, name: 'Volvic Natürliches Mineralwasser 1,5L', brand: 'Volvic', amount: 1.5, unit: 'l', bio: false, pl: false, aliases: ['volvic'], pLidl: 109, pAldi: 109, pRewe: 119 },
  { cat: 6, name: 'Apfelsaft naturtrüb 100% 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['apfelsaft naturtrüb', 'apfelsaft'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 6, name: 'Apfelschorle 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['apfelschorle'], pLidl: 79, pAldi: 79, pRewe: 89 },
  { cat: 6, name: 'Orangensaft 100% Direktsaft 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['orangensaft', 'o saft', 'direktsaft'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 6, name: 'Hohes C Orange 1L', brand: 'Hohes C', amount: 1.0, unit: 'l', bio: false, pl: false, aliases: ['hohes c'], pLidl: 219, pAldi: 219, pRewe: 229 },
  { cat: 6, name: 'Multivitaminsaft 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['multivitaminsaft', 'multisaft'], pLidl: 149, pAldi: 149, pRewe: 169 },
  { cat: 6, name: 'Cola 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['cola', 'cola eigenmarke'], pLidl: 49, pAldi: 49, pRewe: 55 },
  { cat: 6, name: 'Cola Zero 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['cola zero eigenmarke'], pLidl: 49, pAldi: 49, pRewe: 55 },
  { cat: 6, name: 'Coca-Cola Original 1,5L', brand: 'Coca-Cola', amount: 1.5, unit: 'l', bio: false, pl: false, aliases: ['coca cola', 'coke'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 6, name: 'Coca-Cola Zero Sugar 1,5L', brand: 'Coca-Cola', amount: 1.5, unit: 'l', bio: false, pl: false, aliases: ['coca cola zero', 'coke zero'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 6, name: 'Fanta Orange 1,5L', brand: 'Fanta', amount: 1.5, unit: 'l', bio: false, pl: false, aliases: ['fanta'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 6, name: 'Sprite 1,5L', brand: 'Sprite', amount: 1.5, unit: 'l', bio: false, pl: false, aliases: ['sprite'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 6, name: 'Eistee Pfirsich 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['eistee', 'eistee pfirsich'], pLidl: 85, pAldi: 85, pRewe: 95 },
  { cat: 6, name: 'Eistee Zitrone 1,5L', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['eistee zitrone'], pLidl: 85, pAldi: 85, pRewe: 95 },
  { cat: 6, name: 'Energy Drink Original 250ml', brand: 'Eigenmarke', amount: 250, unit: 'ml', bio: false, pl: true, aliases: ['energy drink'], pLidl: 45, pAldi: 45, pRewe: 49 },
  { cat: 6, name: 'Red Bull Energy Drink 250ml', brand: 'Red Bull', amount: 250, unit: 'ml', bio: false, pl: false, aliases: ['red bull'], pLidl: 129, pAldi: 129, pRewe: 139 },
  { cat: 6, name: 'Kaffee Ganze Bohnen Crema 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: false, pl: true, aliases: ['kaffeebohnen', 'kaffee bohnen', 'caffe crema'], pLidl: 999, pAldi: 999, pRewe: 1049 },
  { cat: 6, name: 'Bio Espresso Ganze Bohnen 1kg', brand: 'Eigenmarke', amount: 1.0, unit: 'kg', bio: true, pl: true, aliases: ['espresso bohnen', 'bio kaffee'], pLidl: 1199, pAldi: 1199, pRewe: 1299 },
  { cat: 6, name: 'Lavazza Caffè Crema Bohnen 1kg', brand: 'Lavazza', amount: 1.0, unit: 'kg', bio: false, pl: false, aliases: ['lavazza', 'lavazza bohnen'], pLidl: 1499, pAldi: 1499, pRewe: 1599 },
  { cat: 6, name: 'Filterkaffee gemahlen Röstfein 500g', brand: 'Eigenmarke', amount: 500, unit: 'g', bio: false, pl: true, aliases: ['filterkaffee', 'kaffee pulver'], pLidl: 499, pAldi: 499, pRewe: 529 },
  { cat: 6, name: 'Jacobs Krönung gemahlen 500g', brand: 'Jacobs', amount: 500, unit: 'g', bio: false, pl: false, aliases: ['jacobs krönung', 'jacobs kaffee'], pLidl: 649, pAldi: 649, pRewe: 699 },
  { cat: 6, name: 'Tchibo Feine Milde gemahlen 500g', brand: 'Tchibo', amount: 500, unit: 'g', bio: false, pl: false, aliases: ['tchibo', 'feine milde'], pLidl: 649, pAldi: 649, pRewe: 699 },
  { cat: 6, name: 'Kaffeepads Crema 20er', brand: 'Eigenmarke', amount: 20, unit: 'piece', bio: false, pl: true, aliases: ['kaffeepads', 'pads'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 6, name: 'Schwarzer Tee Ceylon-Assam 50 Beutel', brand: 'Eigenmarke', amount: 50, unit: 'piece', bio: false, pl: true, aliases: ['schwarzer tee', 'tee'], pLidl: 129, pAldi: 129, pRewe: 139 },
  { cat: 6, name: 'Kamillentee 25 Beutel', brand: 'Eigenmarke', amount: 25, unit: 'piece', bio: false, pl: true, aliases: ['kamillentee'], pLidl: 79, pAldi: 79, pRewe: 89 },
  { cat: 6, name: 'Pfefferminztee 25 Beutel', brand: 'Eigenmarke', amount: 25, unit: 'piece', bio: false, pl: true, aliases: ['pfefferminztee', 'minztee'], pLidl: 79, pAldi: 79, pRewe: 89 },
  { cat: 6, name: 'Früchtetee Waldbeere 25 Beutel', brand: 'Eigenmarke', amount: 25, unit: 'piece', bio: false, pl: true, aliases: ['früchtetee'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 6, name: 'Teekanne Kamille 20 Beutel', brand: 'Teekanne', amount: 20, unit: 'piece', bio: false, pl: false, aliases: ['teekanne'], pLidl: 179, pAldi: 189, pRewe: 189 },
  { cat: 6, name: 'Pilsener Bier 0,5L Dose', brand: 'Eigenmarke', amount: 0.5, unit: 'l', bio: false, pl: true, aliases: ['bier dose', 'pils dose'], pLidl: 49, pAldi: 49, pRewe: 55 },
  { cat: 6, name: 'Krombacher Pils 0,5L Flasche', brand: 'Krombacher', amount: 0.5, unit: 'l', bio: false, pl: false, aliases: ['krombacher', 'pils'], pLidl: 89, pAldi: 89, pRewe: 95 },
  { cat: 6, name: 'Bitburger Premium Pils 0,5L Flasche', brand: 'Bitburger', amount: 0.5, unit: 'l', bio: false, pl: false, aliases: ['bitburger', 'bier'], pLidl: 89, pAldi: 89, pRewe: 95 },

  // --- 8. DROGERIE & HAUSHALT (30 Artikel) ---
  { cat: 7, name: 'Toilettenpapier 3-lagig 8x200 Blatt', brand: 'Eigenmarke', amount: 8, unit: 'piece', bio: false, pl: true, aliases: ['klopapier', 'toilettenpapier'], pLidl: 345, pAldi: 345, pRewe: 365 },
  { cat: 7, name: 'Toilettenpapier 4-lagig 8x150 Blatt', brand: 'Eigenmarke', amount: 8, unit: 'piece', bio: false, pl: true, aliases: ['klopapier 4 lagig'], pLidl: 375, pAldi: 375, pRewe: 395 },
  { cat: 7, name: 'Küchenrolle 3-lagig 4x51 Blatt', brand: 'Eigenmarke', amount: 4, unit: 'piece', bio: false, pl: true, aliases: ['küchenrolle', 'küchenpapier', 'zewa'], pLidl: 225, pAldi: 225, pRewe: 245 },
  { cat: 7, name: 'Papiertaschentücher Box 100er', brand: 'Eigenmarke', amount: 100, unit: 'piece', bio: false, pl: true, aliases: ['taschentücher box', 'kosmetiktücher'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 7, name: 'Papiertaschentücher 30x10 Stück', brand: 'Eigenmarke', amount: 30, unit: 'piece', bio: false, pl: true, aliases: ['taschentücher', 'tempo eigenmarke'], pLidl: 245, pAldi: 245, pRewe: 265 },
  { cat: 7, name: 'Tempo Taschentücher 30x10er', brand: 'Tempo', amount: 30, unit: 'piece', bio: false, pl: false, aliases: ['tempo'], pLidl: 369, pAldi: 379, pRewe: 379 },
  { cat: 7, name: 'Geschirrspülmittel Ultra 500ml', brand: 'Eigenmarke', amount: 500, unit: 'ml', bio: false, pl: true, aliases: ['spüli', 'spülmittel'], pLidl: 95, pAldi: 95, pRewe: 105 },
  { cat: 7, name: 'Pril Original Spülmittel 675ml', brand: 'Pril', amount: 675, unit: 'ml', bio: false, pl: false, aliases: ['pril'], pLidl: 199, pAldi: 209, pRewe: 219 },
  { cat: 7, name: 'Spülmaschinentabs All-in-1 40 Stück', brand: 'Eigenmarke', amount: 40, unit: 'piece', bio: false, pl: true, aliases: ['spülmaschinentabs', 'tabs spülmaschine'], pLidl: 345, pAldi: 345, pRewe: 375 },
  { cat: 7, name: 'Somat Gold Spülmaschinentabs 40 Stück', brand: 'Somat', amount: 40, unit: 'piece', bio: false, pl: false, aliases: ['somat tabs'], pLidl: 799, pAldi: 829, pRewe: 849 },
  { cat: 7, name: 'Spezialsalz Spülmaschine 2kg', brand: 'Eigenmarke', amount: 2.0, unit: 'kg', bio: false, pl: true, aliases: ['spülmaschinensalz'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 7, name: 'Klarspüler Spülmaschine 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['klarspüler'], pLidl: 129, pAldi: 129, pRewe: 139 },
  { cat: 7, name: 'Allzweckreiniger Frischeduft 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['allzweckreiniger', 'putzmittel'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 7, name: 'Meister Proper Allzweckreiniger 1L', brand: 'Meister Proper', amount: 1.0, unit: 'l', bio: false, pl: false, aliases: ['meister proper'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 7, name: 'Badreiniger Spray 750ml', brand: 'Eigenmarke', amount: 750, unit: 'ml', bio: false, pl: true, aliases: ['badreiniger'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 7, name: 'WC-Reinigungsgel 750ml', brand: 'Eigenmarke', amount: 750, unit: 'ml', bio: false, pl: true, aliases: ['wc reiniger', 'kloreiniger'], pLidl: 99, pAldi: 99, pRewe: 109 },
  { cat: 7, name: 'Colorwaschmittel flüssig 20 WL', brand: 'Eigenmarke', amount: 1.5, unit: 'l', bio: false, pl: true, aliases: ['waschmittel', 'colorwaschmittel'], pLidl: 345, pAldi: 345, pRewe: 365 },
  { cat: 7, name: 'Vollwaschmittel Pulver 20 WL', brand: 'Eigenmarke', amount: 1.35, unit: 'kg', bio: false, pl: true, aliases: ['vollwaschmittel', 'waschpulver'], pLidl: 345, pAldi: 345, pRewe: 365 },
  { cat: 7, name: 'Ariel Vollwaschmittel Pulver 80 WL', brand: 'Ariel', amount: 5.2, unit: 'kg', bio: false, pl: false, aliases: ['ariel waschmittel'], pLidl: 1999, pAldi: 1999, pRewe: 2199 },
  { cat: 7, name: 'Zahnpasta Kräuter 125ml', brand: 'Eigenmarke', amount: 125, unit: 'ml', bio: false, pl: true, aliases: ['zahnpasta', 'zahncreme'], pLidl: 75, pAldi: 75, pRewe: 79 },
  { cat: 7, name: 'Colgate Total Original 75ml', brand: 'Colgate', amount: 75, unit: 'ml', bio: false, pl: false, aliases: ['colgate'], pLidl: 249, pAldi: 249, pRewe: 269 },
  { cat: 7, name: 'Zahnbürsten Mittel 2er', brand: 'Eigenmarke', amount: 2, unit: 'piece', bio: false, pl: true, aliases: ['zahnbürste', 'zahnbürsten'], pLidl: 85, pAldi: 85, pRewe: 95 },
  { cat: 7, name: 'Duschgel Men Fresh 300ml', brand: 'Eigenmarke', amount: 300, unit: 'ml', bio: false, pl: true, aliases: ['duschgel men', 'duschgel'], pLidl: 85, pAldi: 85, pRewe: 95 },
  { cat: 7, name: 'Duschgel Mandelmilch 300ml', brand: 'Eigenmarke', amount: 300, unit: 'ml', bio: false, pl: true, aliases: ['duschgel pflege'], pLidl: 85, pAldi: 85, pRewe: 95 },
  { cat: 7, name: 'Nivea Pflegedusche Creme Soft 250ml', brand: 'Nivea', amount: 250, unit: 'ml', bio: false, pl: false, aliases: ['nivea duschgel', 'nivea'], pLidl: 189, pAldi: 189, pRewe: 199 },
  { cat: 7, name: 'Flüssigseife Nachfüllbeutel 1L', brand: 'Eigenmarke', amount: 1.0, unit: 'l', bio: false, pl: true, aliases: ['seife', 'flüssigseife', 'handseife'], pLidl: 119, pAldi: 119, pRewe: 129 },
  { cat: 7, name: 'Müllbeutel mit Zugband 35L 30er', brand: 'Eigenmarke', amount: 30, unit: 'piece', bio: false, pl: true, aliases: ['müllbeutel', 'mülltüten', 'müllbeutel 35l'], pLidl: 139, pAldi: 139, pRewe: 149 },
  { cat: 7, name: 'Müllbeutel mit Zugband 60L 20er', brand: 'Eigenmarke', amount: 20, unit: 'piece', bio: false, pl: true, aliases: ['müllbeutel 60l'], pLidl: 149, pAldi: 149, pRewe: 159 },
  { cat: 7, name: 'Alufolie 30m', brand: 'Eigenmarke', amount: 1, unit: 'piece', bio: false, pl: true, aliases: ['alufolie'], pLidl: 199, pAldi: 199, pRewe: 219 },
  { cat: 7, name: 'Backpapier Zuschnitte 30 Bögen', brand: 'Eigenmarke', amount: 30, unit: 'piece', bio: false, pl: true, aliases: ['backpapier'], pLidl: 119, pAldi: 119, pRewe: 129 }
];

console.log(`Total master templates defined: ${rawProductTemplates.length}`);

// Generate UUID for each product deterministically
function generateProductUUID(index) {
  const hex = (index + 1).toString(16).padStart(12, '0');
  return `22222222-0000-0000-0000-${hex}`;
}

const finalProducts = [];
const finalAliases = [];
const finalPrices = [];

rawProductTemplates.forEach((item, idx) => {
  const prodId = generateProductUUID(idx);
  const catId = categories[item.cat].id;
  const barcode = `400000${(100000 + idx)}`;

  finalProducts.push({
    id: prodId,
    category_id: catId,
    gtin_barcode: barcode,
    name: item.name,
    brand: item.brand,
    quantity_amount: item.amount,
    quantity_unit: item.unit,
    is_bio: item.bio,
    is_private_label: item.pl,
  });

  // Aliases
  item.aliases.forEach((alias, aIdx) => {
    finalAliases.push({
      product_id: prodId,
      alias: alias.toLowerCase().trim(),
      priority: 10 - aIdx
    });
  });

  // Prices for chains: Lidl, Aldi (Nord/Süd identical standard), Rewe
  finalPrices.push({
    product_id: prodId,
    chain: 'lidl',
    price_cents: item.pLidl,
    source: 'manual_seed',
    trust_status: 'official'
  });

  finalPrices.push({
    product_id: prodId,
    chain: 'aldi_sued',
    price_cents: item.pAldi,
    source: 'manual_seed',
    trust_status: 'official'
  });

  finalPrices.push({
    product_id: prodId,
    chain: 'aldi_nord',
    price_cents: item.pAldi,
    source: 'manual_seed',
    trust_status: 'official'
  });

  finalPrices.push({
    product_id: prodId,
    chain: 'rewe',
    price_cents: item.pRewe,
    source: 'manual_seed',
    trust_status: 'official'
  });

  // Netto pricing: competitive discounter, especially strong in Obst (fresh fruit specials)
  let pNetto = item.pNetto;
  if (!pNetto) {
    if (item.cat === 0 && item.aliases.some(a => ['banane', 'apfel', 'heidelbeeren', 'erdbeeren', 'zitrone', 'avocado'].some(k => a.includes(k)))) {
      pNetto = Math.round(item.pAldi * 0.90); // 10% fruit special discount at Netto
    } else {
      pNetto = item.pAldi;
    }
  }

  finalPrices.push({
    product_id: prodId,
    chain: 'netto',
    price_cents: pNetto,
    source: 'manual_seed',
    trust_status: 'official'
  });
});

// Category slugs mapping
const categorySlugMap = {
  0: 'obst_gemuese',
  1: 'molkerei_eier',
  2: 'brot_backwaren',
  3: 'fleisch_fisch',
  4: 'vorrat_teigwaren',
  5: 'suesses_snacks',
  6: 'getraenke_kaffee',
  7: 'drogerie_haushalt'
};

// Write JSON export
const jsonExport = {
  version: '2.0',
  exported_at: new Date().toISOString(),
  categories: categories,
  products_count: finalProducts.length,
  products: finalProducts.map((p, idx) => {
    const rawTemplate = rawProductTemplates[idx];
    const aliases = finalAliases.filter(a => a.product_id === p.id).map(a => a.alias);
    const prices = finalPrices.filter(pr => pr.product_id === p.id);
    return {
      ...p,
      category_slug: categorySlugMap[rawTemplate.cat] || 'allgemein',
      aliases,
      prices: {
        lidl: prices.find(x => x.chain === 'lidl')?.price_cents,
        aldi_nord: prices.find(x => x.chain === 'aldi_nord')?.price_cents,
        aldi_sued: prices.find(x => x.chain === 'aldi_sued')?.price_cents,
        netto: prices.find(x => x.chain === 'netto')?.price_cents,
        rewe: prices.find(x => x.chain === 'rewe')?.price_cents,
      }
    };
  })
};

const jsonPath = path.join(__dirname, 'test_data', 'products_seed_250.json');
fs.writeFileSync(jsonPath, JSON.stringify(jsonExport, null, 2), 'utf8');
console.log(`Saved JSON dataset to ${jsonPath} (${finalProducts.length} products)`);

// Generate SQL Seed File
let sql = `-- ============================================================================
-- Seed File: 20261018000003_seed_catalog_250.sql
-- Description: Inserts categories, 250 staple everyday products, aliases, and prices
-- ============================================================================

-- 1. Insert Categories
`;

categories.forEach(c => {
  sql += `INSERT INTO public.categories (id, name, icon) VALUES ('${c.id}', '${c.name}', '${c.icon}') ON CONFLICT (id) DO NOTHING;\n`;
});

sql += `\n-- 2. Insert Products\n`;
finalProducts.forEach(p => {
  const brandVal = p.brand ? `'${p.brand}'` : 'NULL';
  sql += `INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('${p.id}', '${p.category_id}', '${p.gtin_barcode}', '${p.name.replace(/'/g, "''")}', ${brandVal}, ${p.quantity_amount}, '${p.quantity_unit}', ${p.is_bio}, ${p.is_private_label})
ON CONFLICT (id) DO NOTHING;\n`;
});

sql += `\n-- 3. Insert Product Aliases\n`;
finalAliases.forEach(a => {
  sql += `INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('${a.product_id}', '${a.alias.replace(/'/g, "''")}', ${a.priority});\n`;
});

sql += `\n-- 4. Insert Default Chain Prices\n`;
finalPrices.forEach(pr => {
  sql += `INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('${pr.product_id}', '${pr.chain}', ${pr.price_cents}, '${pr.source}', '${pr.trust_status}', 1.00);\n`;
});

const sqlPath = path.join(__dirname, 'supabase', 'migrations', '20261018000003_seed_catalog_250.sql');
fs.writeFileSync(sqlPath, sql, 'utf8');
console.log(`Saved SQL seed to ${sqlPath}`);
