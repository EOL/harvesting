  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"kingdom", :parent_resource_pk=>nil, :resource_pk=>"Animalia"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Animalia", :verbatim=>"Animalia", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia -> ["Hyaena hyaena (Linnaeus, 1758)"]
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"phylum", :parent_resource_pk=>"Animalia", :resource_pk=>"Chordata"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Chordata", :verbatim=>"Chordata", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata -> ["Hyaena hyaena (Linnaeus, 1758)"]
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"class", :parent_resource_pk=>"Chordata", :resource_pk=>"Mammalia"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Mammalia", :verbatim=>"Mammalia", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia -> ["Hyaena hyaena (Linnaeus, 1758)"]
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"order", :parent_resource_pk=>"Mammalia", :resource_pk=>"Carnivora"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Carnivora", :verbatim=>"Carnivora", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora -> ["Hyaena hyaena (Linnaeus, 1758)"]
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Hyaenidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Hyaenidae", :verbatim=>"Hyaenidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Hyaenidae -> ["Hyaena hyaena (Linnaeus, 1758)"]
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Parahyaena brunnea (Thunberg, 1820)"`: Animalia
++ Re-using ancestor for `"Parahyaena brunnea (Thunberg, 1820)"`: Animalia->Chordata
++ Re-using ancestor for `"Parahyaena brunnea (Thunberg, 1820)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Parahyaena brunnea (Thunberg, 1820)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Parahyaena brunnea (Thunberg, 1820)"`: Animalia->Chordata->Mammalia->Carnivora->Hyaenidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Hydrurga leptonyx (de Blainville, 1820)"`: Animalia
++ Re-using ancestor for `"Hydrurga leptonyx (de Blainville, 1820)"`: Animalia->Chordata
++ Re-using ancestor for `"Hydrurga leptonyx (de Blainville, 1820)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Hydrurga leptonyx (de Blainville, 1820)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Phocidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Phocidae", :verbatim=>"Phocidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Phocidae -> ["Hydrurga leptonyx (de Blainville, 1820)"]
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leopardus pardalis (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Leopardus pardalis (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Leopardus pardalis (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leopardus pardalis (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Felidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Felidae", :verbatim=>"Felidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Felidae -> ["Leopardus pardalis (Linnaeus, 1758)"]
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leopardus wiedii (Schinz, 1821)"`: Animalia
++ Re-using ancestor for `"Leopardus wiedii (Schinz, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Leopardus wiedii (Schinz, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leopardus wiedii (Schinz, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leopardus wiedii (Schinz, 1821)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leptailurus serval (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Leptailurus serval (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Leptailurus serval (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leptailurus serval (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leptailurus serval (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leptonychotes weddellii (Lesson, 1826)"`: Animalia
++ Re-using ancestor for `"Leptonychotes weddellii (Lesson, 1826)"`: Animalia->Chordata
++ Re-using ancestor for `"Leptonychotes weddellii (Lesson, 1826)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leptonychotes weddellii (Lesson, 1826)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leptonychotes weddellii (Lesson, 1826)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Liberiictis kuhni Hayman, 1958"`: Animalia
++ Re-using ancestor for `"Liberiictis kuhni Hayman, 1958"`: Animalia->Chordata
++ Re-using ancestor for `"Liberiictis kuhni Hayman, 1958"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Liberiictis kuhni Hayman, 1958"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Herpestidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Herpestidae", :verbatim=>"Herpestidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Herpestidae -> ["Liberiictis kuhni Hayman, 1958"]
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lobodon carcinophaga (Hombron & Jacquinot, 1842)"`: Animalia
++ Re-using ancestor for `"Lobodon carcinophaga (Hombron & Jacquinot, 1842)"`: Animalia->Chordata
++ Re-using ancestor for `"Lobodon carcinophaga (Hombron & Jacquinot, 1842)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lobodon carcinophaga (Hombron & Jacquinot, 1842)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lobodon carcinophaga (Hombron & Jacquinot, 1842)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lontra canadensis (Schreber, 1777)"`: Animalia
++ Re-using ancestor for `"Lontra canadensis (Schreber, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Lontra canadensis (Schreber, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lontra canadensis (Schreber, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Mustelidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Mustelidae", :verbatim=>"Mustelidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Mustelidae -> ["Lontra canadensis (Schreber, 1777)"]
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lontra felina (Molina, 1782)"`: Animalia
++ Re-using ancestor for `"Lontra felina (Molina, 1782)"`: Animalia->Chordata
++ Re-using ancestor for `"Lontra felina (Molina, 1782)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lontra felina (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lontra felina (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lontra longicaudis (Olfers, 1818)"`: Animalia
++ Re-using ancestor for `"Lontra longicaudis (Olfers, 1818)"`: Animalia->Chordata
++ Re-using ancestor for `"Lontra longicaudis (Olfers, 1818)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lontra longicaudis (Olfers, 1818)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lontra longicaudis (Olfers, 1818)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lontra provocax (Thomas, 1908)"`: Animalia
++ Re-using ancestor for `"Lontra provocax (Thomas, 1908)"`: Animalia->Chordata
++ Re-using ancestor for `"Lontra provocax (Thomas, 1908)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lontra provocax (Thomas, 1908)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lontra provocax (Thomas, 1908)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lutra lutra (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Lutra lutra (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Lutra lutra (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lutra lutra (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lutra lutra (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Hydrictis maculicollis (Lichtenstein, 1835)"`: Animalia
++ Re-using ancestor for `"Hydrictis maculicollis (Lichtenstein, 1835)"`: Animalia->Chordata
++ Re-using ancestor for `"Hydrictis maculicollis (Lichtenstein, 1835)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Hydrictis maculicollis (Lichtenstein, 1835)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Hydrictis maculicollis (Lichtenstein, 1835)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lutra sumatrana (Gray, 1865)"`: Animalia
++ Re-using ancestor for `"Lutra sumatrana (Gray, 1865)"`: Animalia->Chordata
++ Re-using ancestor for `"Lutra sumatrana (Gray, 1865)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lutra sumatrana (Gray, 1865)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lutra sumatrana (Gray, 1865)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lutrogale perspicillata (I. Geoffroy Saint-Hilaire, 1826)"`: Animalia
++ Re-using ancestor for `"Lutrogale perspicillata (I. Geoffroy Saint-Hilaire, 1826)"`: Animalia->Chordata
++ Re-using ancestor for `"Lutrogale perspicillata (I. Geoffroy Saint-Hilaire, 1826)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lutrogale perspicillata (I. Geoffroy Saint-Hilaire, 1826)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lutrogale perspicillata (I. Geoffroy Saint-Hilaire, 1826)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lycaon pictus (Temminck, 1820)"`: Animalia
++ Re-using ancestor for `"Lycaon pictus (Temminck, 1820)"`: Animalia->Chordata
++ Re-using ancestor for `"Lycaon pictus (Temminck, 1820)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lycaon pictus (Temminck, 1820)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Canidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Canidae", :verbatim=>"Canidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Canidae -> ["Lycaon pictus (Temminck, 1820)"]
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lynx canadensis Kerr, 1792"`: Animalia
++ Re-using ancestor for `"Lynx canadensis Kerr, 1792"`: Animalia->Chordata
++ Re-using ancestor for `"Lynx canadensis Kerr, 1792"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lynx canadensis Kerr, 1792"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lynx canadensis Kerr, 1792"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lynx lynx (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Lynx lynx (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Lynx lynx (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lynx lynx (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lynx lynx (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lynx pardinus (Temminck, 1827)"`: Animalia
++ Re-using ancestor for `"Lynx pardinus (Temminck, 1827)"`: Animalia->Chordata
++ Re-using ancestor for `"Lynx pardinus (Temminck, 1827)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lynx pardinus (Temminck, 1827)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lynx pardinus (Temminck, 1827)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lynx rufus (Schreber, 1777)"`: Animalia
++ Re-using ancestor for `"Lynx rufus (Schreber, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Lynx rufus (Schreber, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lynx rufus (Schreber, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lynx rufus (Schreber, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Macrogalidia musschenbroekii (Schlegel, 1877)"`: Animalia
++ Re-using ancestor for `"Macrogalidia musschenbroekii (Schlegel, 1877)"`: Animalia->Chordata
++ Re-using ancestor for `"Macrogalidia musschenbroekii (Schlegel, 1877)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Macrogalidia musschenbroekii (Schlegel, 1877)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Viverridae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Viverridae", :verbatim=>"Viverridae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Viverridae -> ["Macrogalidia musschenbroekii (Schlegel, 1877)"]
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes gwatkinsii Horsfield, 1851"`: Animalia
++ Re-using ancestor for `"Martes gwatkinsii Horsfield, 1851"`: Animalia->Chordata
++ Re-using ancestor for `"Martes gwatkinsii Horsfield, 1851"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes gwatkinsii Horsfield, 1851"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes gwatkinsii Horsfield, 1851"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes martes (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Martes martes (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Martes martes (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes martes (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes martes (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Melogale everetti (Thomas, 1895)"`: Animalia
++ Re-using ancestor for `"Melogale everetti (Thomas, 1895)"`: Animalia->Chordata
++ Re-using ancestor for `"Melogale everetti (Thomas, 1895)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Melogale everetti (Thomas, 1895)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Melogale everetti (Thomas, 1895)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Melursus ursinus (Shaw, 1791)"`: Animalia
++ Re-using ancestor for `"Melursus ursinus (Shaw, 1791)"`: Animalia->Chordata
++ Re-using ancestor for `"Melursus ursinus (Shaw, 1791)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Melursus ursinus (Shaw, 1791)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Ursidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Ursidae", :verbatim=>"Ursidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Ursidae -> ["Melursus ursinus (Shaw, 1791)"]
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mirounga angustirostris (Gill, 1866)"`: Animalia
++ Re-using ancestor for `"Mirounga angustirostris (Gill, 1866)"`: Animalia->Chordata
++ Re-using ancestor for `"Mirounga angustirostris (Gill, 1866)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mirounga angustirostris (Gill, 1866)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mirounga angustirostris (Gill, 1866)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mirounga leonina (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Mirounga leonina (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Mirounga leonina (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mirounga leonina (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mirounga leonina (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta bourloni Gaubert, 2003"`: Animalia
++ Re-using ancestor for `"Genetta bourloni Gaubert, 2003"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta bourloni Gaubert, 2003"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta bourloni Gaubert, 2003"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta bourloni Gaubert, 2003"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Meles anakuma Temminck, 1844"`: Animalia
++ Re-using ancestor for `"Meles anakuma Temminck, 1844"`: Animalia->Chordata
++ Re-using ancestor for `"Meles anakuma Temminck, 1844"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Meles anakuma Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Meles anakuma Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Meles leucurus (Hodgson, 1847)"`: Animalia
++ Re-using ancestor for `"Meles leucurus (Hodgson, 1847)"`: Animalia->Chordata
++ Re-using ancestor for `"Meles leucurus (Hodgson, 1847)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Meles leucurus (Hodgson, 1847)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Meles leucurus (Hodgson, 1847)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta poensis Waterhouse, 1838"`: Animalia
++ Re-using ancestor for `"Genetta poensis Waterhouse, 1838"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta poensis Waterhouse, 1838"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta poensis Waterhouse, 1838"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta poensis Waterhouse, 1838"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta pardina I. Geoffroy Saint-Hilaire, 1832"`: Animalia
++ Re-using ancestor for `"Genetta pardina I. Geoffroy Saint-Hilaire, 1832"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta pardina I. Geoffroy Saint-Hilaire, 1832"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta pardina I. Geoffroy Saint-Hilaire, 1832"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta pardina I. Geoffroy Saint-Hilaire, 1832"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Cryptoprocta spelea Grandidier, 1902"`: Animalia
++ Re-using ancestor for `"Cryptoprocta spelea Grandidier, 1902"`: Animalia->Chordata
++ Re-using ancestor for `"Cryptoprocta spelea Grandidier, 1902"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Cryptoprocta spelea Grandidier, 1902"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Eupleridae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Eupleridae", :verbatim=>"Eupleridae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Eupleridae -> ["Cryptoprocta spelea Grandidier, 1902"]
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Monachus monachus (Hermann, 1779)"`: Animalia
++ Re-using ancestor for `"Monachus monachus (Hermann, 1779)"`: Animalia->Chordata
++ Re-using ancestor for `"Monachus monachus (Hermann, 1779)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Monachus monachus (Hermann, 1779)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Monachus monachus (Hermann, 1779)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neomonachus schauinslandi (Matschie, 1905)"`: Animalia
++ Re-using ancestor for `"Neomonachus schauinslandi (Matschie, 1905)"`: Animalia->Chordata
++ Re-using ancestor for `"Neomonachus schauinslandi (Matschie, 1905)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neomonachus schauinslandi (Matschie, 1905)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neomonachus schauinslandi (Matschie, 1905)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neomonachus tropicalis (Gray, 1850)"`: Animalia
++ Re-using ancestor for `"Neomonachus tropicalis (Gray, 1850)"`: Animalia->Chordata
++ Re-using ancestor for `"Neomonachus tropicalis (Gray, 1850)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neomonachus tropicalis (Gray, 1850)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neomonachus tropicalis (Gray, 1850)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neofelis diardi (G. Cuvier, 1823)"`: Animalia
++ Re-using ancestor for `"Neofelis diardi (G. Cuvier, 1823)"`: Animalia->Chordata
++ Re-using ancestor for `"Neofelis diardi (G. Cuvier, 1823)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neofelis diardi (G. Cuvier, 1823)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neofelis diardi (G. Cuvier, 1823)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Spilogale angustifrons Howell, 1902"`: Animalia
++ Re-using ancestor for `"Spilogale angustifrons Howell, 1902"`: Animalia->Chordata
++ Re-using ancestor for `"Spilogale angustifrons Howell, 1902"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Spilogale angustifrons Howell, 1902"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Mephitidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Mephitidae", :verbatim=>"Mephitidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Mephitidae -> ["Spilogale angustifrons Howell, 1902"]
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Bdeogale omnivora Heller, 1913"`: Animalia
++ Re-using ancestor for `"Bdeogale omnivora Heller, 1913"`: Animalia->Chordata
++ Re-using ancestor for `"Bdeogale omnivora Heller, 1913"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Bdeogale omnivora Heller, 1913"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Bdeogale omnivora Heller, 1913"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Spilogale gracilis Merriam, 1890"`: Animalia
++ Re-using ancestor for `"Spilogale gracilis Merriam, 1890"`: Animalia->Chordata
++ Re-using ancestor for `"Spilogale gracilis Merriam, 1890"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Spilogale gracilis Merriam, 1890"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Spilogale gracilis Merriam, 1890"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. corbetti Mazak, 1968"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. corbetti Mazak, 1968"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. corbetti Mazak, 1968"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. corbetti Mazak, 1968"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. corbetti Mazak, 1968"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neofelis diardi ssp. diardi (G. Cuvier, 1823)"`: Animalia
++ Re-using ancestor for `"Neofelis diardi ssp. diardi (G. Cuvier, 1823)"`: Animalia->Chordata
++ Re-using ancestor for `"Neofelis diardi ssp. diardi (G. Cuvier, 1823)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neofelis diardi ssp. diardi (G. Cuvier, 1823)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neofelis diardi ssp. diardi (G. Cuvier, 1823)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leopardus tigrinus ssp. oncilla (Thomas, 1903)"`: Animalia
++ Re-using ancestor for `"Leopardus tigrinus ssp. oncilla (Thomas, 1903)"`: Animalia->Chordata
++ Re-using ancestor for `"Leopardus tigrinus ssp. oncilla (Thomas, 1903)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leopardus tigrinus ssp. oncilla (Thomas, 1903)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leopardus tigrinus ssp. oncilla (Thomas, 1903)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionailurus bengalensis ssp. rabori Groves, 1997"`: Animalia
++ Re-using ancestor for `"Prionailurus bengalensis ssp. rabori Groves, 1997"`: Animalia->Chordata
++ Re-using ancestor for `"Prionailurus bengalensis ssp. rabori Groves, 1997"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionailurus bengalensis ssp. rabori Groves, 1997"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Prionailurus bengalensis ssp. rabori Groves, 1997"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. jacksoni Luo, Kim, Johnson, van der Walt, Martenson, Yuhki, Miquelle, Uphyrkina, Goodrich, Quigley, Tilson, Brady, Martelli, Subramaniam, McDougal, Hean, Huang, Pan, Karanth, Sunquist, Smith & O'Brien, 2004"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. jacksoni Luo, Kim, Johnson, van der Walt, Martenson, Yuhki, Miquelle, Uphyrkina, Goodrich, Quigley, Tilson, Brady, Martelli, Subramaniam, McDougal, Hean, Huang, Pan, Karanth, Sunquist, Smith & O'Brien, 2004"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. jacksoni Luo, Kim, Johnson, van der Walt, Martenson, Yuhki, Miquelle, Uphyrkina, Goodrich, Quigley, Tilson, Brady, Martelli, Subramaniam, McDougal, Hean, Huang, Pan, Karanth, Sunquist, Smith & O'Brien, 2004"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. jacksoni Luo, Kim, Johnson, van der Walt, Martenson, Yuhki, Miquelle, Uphyrkina, Goodrich, Quigley, Tilson, Brady, Martelli, Subramaniam, McDougal, Hean, Huang, Pan, Karanth, Sunquist, Smith & O'Brien, 2004"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. jacksoni Luo, Kim, Johnson, van der Walt, Martenson, Yuhki, Miquelle, Uphyrkina, Goodrich, Quigley, Tilson, Brady, Martelli, Subramaniam, McDougal, Hean, Huang, Pan, Karanth, Sunquist, Smith & O'Brien, 2004"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. tigris (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. tigris (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. tigris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. tigris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. tigris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neofelis diardi ssp. borneensis Wilting, Buckley-Beason, Feldhaar, Gadau, O'Brien & Linsenmair, 2007"`: Animalia
++ Re-using ancestor for `"Neofelis diardi ssp. borneensis Wilting, Buckley-Beason, Feldhaar, Gadau, O'Brien & Linsenmair, 2007"`: Animalia->Chordata
++ Re-using ancestor for `"Neofelis diardi ssp. borneensis Wilting, Buckley-Beason, Feldhaar, Gadau, O'Brien & Linsenmair, 2007"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neofelis diardi ssp. borneensis Wilting, Buckley-Beason, Feldhaar, Gadau, O'Brien & Linsenmair, 2007"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neofelis diardi ssp. borneensis Wilting, Buckley-Beason, Feldhaar, Gadau, O'Brien & Linsenmair, 2007"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mungos gambianus (Ogilby, 1835)"`: Animalia
++ Re-using ancestor for `"Mungos gambianus (Ogilby, 1835)"`: Animalia->Chordata
++ Re-using ancestor for `"Mungos gambianus (Ogilby, 1835)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mungos gambianus (Ogilby, 1835)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mungos gambianus (Ogilby, 1835)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mungotictis decemlineata (A. Grandidier, 1867)"`: Animalia
++ Re-using ancestor for `"Mungotictis decemlineata (A. Grandidier, 1867)"`: Animalia->Chordata
++ Re-using ancestor for `"Mungotictis decemlineata (A. Grandidier, 1867)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mungotictis decemlineata (A. Grandidier, 1867)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mungotictis decemlineata (A. Grandidier, 1867)"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela lutreola (Linnaeus, 1761)"`: Animalia
++ Re-using ancestor for `"Mustela lutreola (Linnaeus, 1761)"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela lutreola (Linnaeus, 1761)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela lutreola (Linnaeus, 1761)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela lutreola (Linnaeus, 1761)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela lutreolina Robinson & Thomas, 1917"`: Animalia
++ Re-using ancestor for `"Mustela lutreolina Robinson & Thomas, 1917"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela lutreolina Robinson & Thomas, 1917"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela lutreolina Robinson & Thomas, 1917"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela lutreolina Robinson & Thomas, 1917"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela nigripes (Audubon & Bachman, 1851)"`: Animalia
++ Re-using ancestor for `"Mustela nigripes (Audubon & Bachman, 1851)"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela nigripes (Audubon & Bachman, 1851)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela nigripes (Audubon & Bachman, 1851)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela nigripes (Audubon & Bachman, 1851)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela africana Desmarest, 1818"`: Animalia
++ Re-using ancestor for `"Mustela africana Desmarest, 1818"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela africana Desmarest, 1818"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela africana Desmarest, 1818"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela africana Desmarest, 1818"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela felipei Izor & de la Torre, 1978"`: Animalia
++ Re-using ancestor for `"Mustela felipei Izor & de la Torre, 1978"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela felipei Izor & de la Torre, 1978"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela felipei Izor & de la Torre, 1978"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela felipei Izor & de la Torre, 1978"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela strigidorsa Gray, 1853"`: Animalia
++ Re-using ancestor for `"Mustela strigidorsa Gray, 1853"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela strigidorsa Gray, 1853"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela strigidorsa Gray, 1853"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela strigidorsa Gray, 1853"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mydaus marchei (Huet, 1887)"`: Animalia
++ Re-using ancestor for `"Mydaus marchei (Huet, 1887)"`: Animalia->Chordata
++ Re-using ancestor for `"Mydaus marchei (Huet, 1887)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mydaus marchei (Huet, 1887)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mydaus marchei (Huet, 1887)"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neofelis nebulosa (Griffith, 1821)"`: Animalia
++ Re-using ancestor for `"Neofelis nebulosa (Griffith, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Neofelis nebulosa (Griffith, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neofelis nebulosa (Griffith, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neofelis nebulosa (Griffith, 1821)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neophoca cinerea (PÌ©ron, 1816)"`: Animalia
++ Re-using ancestor for `"Neophoca cinerea (PÌ©ron, 1816)"`: Animalia->Chordata
++ Re-using ancestor for `"Neophoca cinerea (PÌ©ron, 1816)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neophoca cinerea (PÌ©ron, 1816)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Otariidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Otariidae", :verbatim=>"Otariidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Otariidae -> ["Neophoca cinerea (PÌ©ron, 1816)"]
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Nyctereutes procyonoides (Gray, 1834)"`: Animalia
++ Re-using ancestor for `"Nyctereutes procyonoides (Gray, 1834)"`: Animalia->Chordata
++ Re-using ancestor for `"Nyctereutes procyonoides (Gray, 1834)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Nyctereutes procyonoides (Gray, 1834)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Nyctereutes procyonoides (Gray, 1834)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Odobenus rosmarus (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Odobenus rosmarus (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Odobenus rosmarus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Odobenus rosmarus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Odobenidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Odobenidae", :verbatim=>"Odobenidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Odobenidae -> ["Odobenus rosmarus (Linnaeus, 1758)"]
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ommatophoca rossii (Gray, 1844)"`: Animalia
++ Re-using ancestor for `"Ommatophoca rossii (Gray, 1844)"`: Animalia->Chordata
++ Re-using ancestor for `"Ommatophoca rossii (Gray, 1844)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ommatophoca rossii (Gray, 1844)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ommatophoca rossii (Gray, 1844)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leopardus colocolo (Molina, 1782)"`: Animalia
++ Re-using ancestor for `"Leopardus colocolo (Molina, 1782)"`: Animalia->Chordata
++ Re-using ancestor for `"Leopardus colocolo (Molina, 1782)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leopardus colocolo (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leopardus colocolo (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leopardus geoffroyi (d'Orbigny & Gervais, 1844)"`: Animalia
++ Re-using ancestor for `"Leopardus geoffroyi (d'Orbigny & Gervais, 1844)"`: Animalia->Chordata
++ Re-using ancestor for `"Leopardus geoffroyi (d'Orbigny & Gervais, 1844)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leopardus geoffroyi (d'Orbigny & Gervais, 1844)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leopardus geoffroyi (d'Orbigny & Gervais, 1844)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leopardus guigna (Molina, 1782)"`: Animalia
++ Re-using ancestor for `"Leopardus guigna (Molina, 1782)"`: Animalia->Chordata
++ Re-using ancestor for `"Leopardus guigna (Molina, 1782)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leopardus guigna (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leopardus guigna (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Leopardus jacobita (Cornalia, 1865)"`: Animalia
++ Re-using ancestor for `"Leopardus jacobita (Cornalia, 1865)"`: Animalia->Chordata
++ Re-using ancestor for `"Leopardus jacobita (Cornalia, 1865)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Leopardus jacobita (Cornalia, 1865)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Leopardus jacobita (Cornalia, 1865)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta piscivora (J.A. Allen, 1919)"`: Animalia
++ Re-using ancestor for `"Genetta piscivora (J.A. Allen, 1919)"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta piscivora (J.A. Allen, 1919)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta piscivora (J.A. Allen, 1919)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta piscivora (J.A. Allen, 1919)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Otocolobus manul (Pallas, 1776)"`: Animalia
++ Re-using ancestor for `"Otocolobus manul (Pallas, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Otocolobus manul (Pallas, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Otocolobus manul (Pallas, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Otocolobus manul (Pallas, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Otocyon megalotis (Desmarest, 1822)"`: Animalia
++ Re-using ancestor for `"Otocyon megalotis (Desmarest, 1822)"`: Animalia->Chordata
++ Re-using ancestor for `"Otocyon megalotis (Desmarest, 1822)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Otocyon megalotis (Desmarest, 1822)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Otocyon megalotis (Desmarest, 1822)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera leo (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Panthera leo (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera leo (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera leo (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera leo (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera leo ssp. persica (Meyer, 1826)"`: Animalia
++ Re-using ancestor for `"Panthera leo ssp. persica (Meyer, 1826)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera leo ssp. persica (Meyer, 1826)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera leo ssp. persica (Meyer, 1826)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera leo ssp. persica (Meyer, 1826)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera onca (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Panthera onca (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera onca (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera onca (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera onca (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera pardus (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Panthera pardus (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera pardus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera pardus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera pardus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Panthera tigris (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. altaica Temminck, 1844"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. altaica Temminck, 1844"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. altaica Temminck, 1844"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. altaica Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. altaica Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. amoyensis (Hilzheimer, 1905)"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. amoyensis (Hilzheimer, 1905)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. amoyensis (Hilzheimer, 1905)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. amoyensis (Hilzheimer, 1905)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. amoyensis (Hilzheimer, 1905)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. sumatrae Pocock, 1929"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. sumatrae Pocock, 1929"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. sumatrae Pocock, 1929"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. sumatrae Pocock, 1929"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. sumatrae Pocock, 1929"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Paradoxurus jerdoni Blanford, 1885"`: Animalia
++ Re-using ancestor for `"Paradoxurus jerdoni Blanford, 1885"`: Animalia->Chordata
++ Re-using ancestor for `"Paradoxurus jerdoni Blanford, 1885"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Paradoxurus jerdoni Blanford, 1885"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Paradoxurus jerdoni Blanford, 1885"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pardofelis marmorata (Martin, 1837)"`: Animalia
++ Re-using ancestor for `"Pardofelis marmorata (Martin, 1837)"`: Animalia->Chordata
++ Re-using ancestor for `"Pardofelis marmorata (Martin, 1837)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pardofelis marmorata (Martin, 1837)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pardofelis marmorata (Martin, 1837)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Phoca vitulina Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Phoca vitulina Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Phoca vitulina Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Phoca vitulina Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Phoca vitulina Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Phoca largha (Pallas, 1811)"`: Animalia
++ Re-using ancestor for `"Phoca largha (Pallas, 1811)"`: Animalia->Chordata
++ Re-using ancestor for `"Phoca largha (Pallas, 1811)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Phoca largha (Pallas, 1811)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Phoca largha (Pallas, 1811)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Phocarctos hookeri (Peters, 1866)"`: Animalia
++ Re-using ancestor for `"Phocarctos hookeri (Peters, 1866)"`: Animalia->Chordata
++ Re-using ancestor for `"Phocarctos hookeri (Peters, 1866)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Phocarctos hookeri (Peters, 1866)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Phocarctos hookeri (Peters, 1866)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Eumetopias jubatus ssp. monteriensis (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Eumetopias jubatus ssp. monteriensis (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Eumetopias jubatus ssp. monteriensis (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Eumetopias jubatus ssp. monteriensis (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Eumetopias jubatus ssp. monteriensis (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Eumetopias jubatus ssp. jubatus (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Eumetopias jubatus ssp. jubatus (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Eumetopias jubatus ssp. jubatus (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Eumetopias jubatus ssp. jubatus (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Eumetopias jubatus ssp. jubatus (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Aonyx capensis (Schinz, 1821)"`: Animalia
++ Re-using ancestor for `"Aonyx capensis (Schinz, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Aonyx capensis (Schinz, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Aonyx capensis (Schinz, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Aonyx capensis (Schinz, 1821)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Aonyx congicus LÌ¦nnberg, 1910"`: Animalia
++ Re-using ancestor for `"Aonyx congicus LÌ¦nnberg, 1910"`: Animalia->Chordata
++ Re-using ancestor for `"Aonyx congicus LÌ¦nnberg, 1910"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Aonyx congicus LÌ¦nnberg, 1910"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Aonyx congicus LÌ¦nnberg, 1910"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionailurus bengalensis (Kerr, 1792)"`: Animalia
++ Re-using ancestor for `"Prionailurus bengalensis (Kerr, 1792)"`: Animalia->Chordata
++ Re-using ancestor for `"Prionailurus bengalensis (Kerr, 1792)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionailurus bengalensis (Kerr, 1792)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Prionailurus bengalensis (Kerr, 1792)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionailurus planiceps (Vigors & Horsfield, 1827)"`: Animalia
++ Re-using ancestor for `"Prionailurus planiceps (Vigors & Horsfield, 1827)"`: Animalia->Chordata
++ Re-using ancestor for `"Prionailurus planiceps (Vigors & Horsfield, 1827)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionailurus planiceps (Vigors & Horsfield, 1827)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Prionailurus planiceps (Vigors & Horsfield, 1827)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionailurus rubiginosus (I. Geoffroy Saint-Hilaire, 1831)"`: Animalia
++ Re-using ancestor for `"Prionailurus rubiginosus (I. Geoffroy Saint-Hilaire, 1831)"`: Animalia->Chordata
++ Re-using ancestor for `"Prionailurus rubiginosus (I. Geoffroy Saint-Hilaire, 1831)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionailurus rubiginosus (I. Geoffroy Saint-Hilaire, 1831)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Prionailurus rubiginosus (I. Geoffroy Saint-Hilaire, 1831)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionailurus viverrinus (Bennett, 1833)"`: Animalia
++ Re-using ancestor for `"Prionailurus viverrinus (Bennett, 1833)"`: Animalia->Chordata
++ Re-using ancestor for `"Prionailurus viverrinus (Bennett, 1833)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionailurus viverrinus (Bennett, 1833)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Prionailurus viverrinus (Bennett, 1833)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionailurus bengalensis ssp. iriomotensis Imaizumi, 1967"`: Animalia
++ Re-using ancestor for `"Prionailurus bengalensis ssp. iriomotensis Imaizumi, 1967"`: Animalia->Chordata
++ Re-using ancestor for `"Prionailurus bengalensis ssp. iriomotensis Imaizumi, 1967"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionailurus bengalensis ssp. iriomotensis Imaizumi, 1967"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Prionailurus bengalensis ssp. iriomotensis Imaizumi, 1967"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Procyon pygmaeus Merriam, 1901"`: Animalia
++ Re-using ancestor for `"Procyon pygmaeus Merriam, 1901"`: Animalia->Chordata
++ Re-using ancestor for `"Procyon pygmaeus Merriam, 1901"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Procyon pygmaeus Merriam, 1901"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Procyonidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Procyonidae", :verbatim=>"Procyonidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Procyonidae -> ["Procyon pygmaeus Merriam, 1901"]
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Caracal aurata (Temminck, 1827)"`: Animalia
++ Re-using ancestor for `"Caracal aurata (Temminck, 1827)"`: Animalia->Chordata
++ Re-using ancestor for `"Caracal aurata (Temminck, 1827)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Caracal aurata (Temminck, 1827)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Caracal aurata (Temminck, 1827)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Proteles cristata (Sparrman, 1783)"`: Animalia
++ Re-using ancestor for `"Proteles cristata (Sparrman, 1783)"`: Animalia->Chordata
++ Re-using ancestor for `"Proteles cristata (Sparrman, 1783)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Proteles cristata (Sparrman, 1783)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Proteles cristata (Sparrman, 1783)"`: Animalia->Chordata->Mammalia->Carnivora->Hyaenidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pteronura brasiliensis (Gmelin, 1788)"`: Animalia
++ Re-using ancestor for `"Pteronura brasiliensis (Gmelin, 1788)"`: Animalia->Chordata
++ Re-using ancestor for `"Pteronura brasiliensis (Gmelin, 1788)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pteronura brasiliensis (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pteronura brasiliensis (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Puma concolor (Linnaeus, 1771)"`: Animalia
++ Re-using ancestor for `"Puma concolor (Linnaeus, 1771)"`: Animalia->Chordata
++ Re-using ancestor for `"Puma concolor (Linnaeus, 1771)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Puma concolor (Linnaeus, 1771)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Puma concolor (Linnaeus, 1771)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Salanoia concolor (I. Geoffroy Saint-Hilaire, 1837)"`: Animalia
++ Re-using ancestor for `"Salanoia concolor (I. Geoffroy Saint-Hilaire, 1837)"`: Animalia->Chordata
++ Re-using ancestor for `"Salanoia concolor (I. Geoffroy Saint-Hilaire, 1837)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Salanoia concolor (I. Geoffroy Saint-Hilaire, 1837)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Salanoia concolor (I. Geoffroy Saint-Hilaire, 1837)"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Speothos venaticus (Lund, 1842)"`: Animalia
++ Re-using ancestor for `"Speothos venaticus (Lund, 1842)"`: Animalia->Chordata
++ Re-using ancestor for `"Speothos venaticus (Lund, 1842)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Speothos venaticus (Lund, 1842)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Speothos venaticus (Lund, 1842)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus australis (Zimmermann, 1783)"`: Animalia
++ Re-using ancestor for `"Arctocephalus australis (Zimmermann, 1783)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus australis (Zimmermann, 1783)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus australis (Zimmermann, 1783)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus australis (Zimmermann, 1783)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus galapagoensis Heller, 1904"`: Animalia
++ Re-using ancestor for `"Arctocephalus galapagoensis Heller, 1904"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus galapagoensis Heller, 1904"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus galapagoensis Heller, 1904"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus galapagoensis Heller, 1904"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus gazella (Peters, 1875)"`: Animalia
++ Re-using ancestor for `"Arctocephalus gazella (Peters, 1875)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus gazella (Peters, 1875)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus gazella (Peters, 1875)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus gazella (Peters, 1875)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus philippii (Peters, 1866)"`: Animalia
++ Re-using ancestor for `"Arctocephalus philippii (Peters, 1866)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus philippii (Peters, 1866)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus philippii (Peters, 1866)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus philippii (Peters, 1866)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus pusillus (Schreber, 1775)"`: Animalia
++ Re-using ancestor for `"Arctocephalus pusillus (Schreber, 1775)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus pusillus (Schreber, 1775)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus pusillus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus pusillus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus townsendi Merriam, 1897"`: Animalia
++ Re-using ancestor for `"Arctocephalus townsendi Merriam, 1897"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus townsendi Merriam, 1897"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus townsendi Merriam, 1897"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus townsendi Merriam, 1897"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus tropicalis (J.E. Gray, 1872)"`: Animalia
++ Re-using ancestor for `"Arctocephalus tropicalis (J.E. Gray, 1872)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus tropicalis (J.E. Gray, 1872)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus tropicalis (J.E. Gray, 1872)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus tropicalis (J.E. Gray, 1872)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus australis ssp. australis (Zimmermann, 1783)"`: Animalia
++ Re-using ancestor for `"Arctocephalus australis ssp. australis (Zimmermann, 1783)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus australis ssp. australis (Zimmermann, 1783)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus australis ssp. australis (Zimmermann, 1783)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus australis ssp. australis (Zimmermann, 1783)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus pusillus ssp. pusillus (Schreber, 1775)"`: Animalia
++ Re-using ancestor for `"Arctocephalus pusillus ssp. pusillus (Schreber, 1775)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus pusillus ssp. pusillus (Schreber, 1775)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus pusillus ssp. pusillus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus pusillus ssp. pusillus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus pusillus ssp. doriferus Wood Jones, 1925"`: Animalia
++ Re-using ancestor for `"Arctocephalus pusillus ssp. doriferus Wood Jones, 1925"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus pusillus ssp. doriferus Wood Jones, 1925"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus pusillus ssp. doriferus Wood Jones, 1925"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus pusillus ssp. doriferus Wood Jones, 1925"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Acinonyx jubatus (Schreber, 1775)"`: Animalia
++ Re-using ancestor for `"Acinonyx jubatus (Schreber, 1775)"`: Animalia->Chordata
++ Re-using ancestor for `"Acinonyx jubatus (Schreber, 1775)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Acinonyx jubatus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Acinonyx jubatus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Acinonyx jubatus ssp. venaticus (Griffith, 1821)"`: Animalia
++ Re-using ancestor for `"Acinonyx jubatus ssp. venaticus (Griffith, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Acinonyx jubatus ssp. venaticus (Griffith, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Acinonyx jubatus ssp. venaticus (Griffith, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Acinonyx jubatus ssp. venaticus (Griffith, 1821)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Tremarctos ornatus (F.G. Cuvier, 1825)"`: Animalia
++ Re-using ancestor for `"Tremarctos ornatus (F.G. Cuvier, 1825)"`: Animalia->Chordata
++ Re-using ancestor for `"Tremarctos ornatus (F.G. Cuvier, 1825)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Tremarctos ornatus (F.G. Cuvier, 1825)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Tremarctos ornatus (F.G. Cuvier, 1825)"`: Animalia->Chordata->Mammalia->Carnivora->Ursidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Acinonyx jubatus ssp. hecki Hilzheimer, 1913"`: Animalia
++ Re-using ancestor for `"Acinonyx jubatus ssp. hecki Hilzheimer, 1913"`: Animalia->Chordata
++ Re-using ancestor for `"Acinonyx jubatus ssp. hecki Hilzheimer, 1913"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Acinonyx jubatus ssp. hecki Hilzheimer, 1913"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Acinonyx jubatus ssp. hecki Hilzheimer, 1913"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera uncia (Schreber, 1775)"`: Animalia
++ Re-using ancestor for `"Panthera uncia (Schreber, 1775)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera uncia (Schreber, 1775)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera uncia (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera uncia (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Urocyon cinereoargenteus (Schreber, 1775)"`: Animalia
++ Re-using ancestor for `"Urocyon cinereoargenteus (Schreber, 1775)"`: Animalia->Chordata
++ Re-using ancestor for `"Urocyon cinereoargenteus (Schreber, 1775)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Urocyon cinereoargenteus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Urocyon cinereoargenteus (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Urocyon littoralis (Baird, 1857)"`: Animalia
++ Re-using ancestor for `"Urocyon littoralis (Baird, 1857)"`: Animalia->Chordata
++ Re-using ancestor for `"Urocyon littoralis (Baird, 1857)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Urocyon littoralis (Baird, 1857)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Urocyon littoralis (Baird, 1857)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ursus maritimus Phipps, 1774"`: Animalia
++ Re-using ancestor for `"Ursus maritimus Phipps, 1774"`: Animalia->Chordata
++ Re-using ancestor for `"Ursus maritimus Phipps, 1774"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ursus maritimus Phipps, 1774"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ursus maritimus Phipps, 1774"`: Animalia->Chordata->Mammalia->Carnivora->Ursidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ursus thibetanus G. [Baron] Cuvier, 1823"`: Animalia
++ Re-using ancestor for `"Ursus thibetanus G. [Baron] Cuvier, 1823"`: Animalia->Chordata
++ Re-using ancestor for `"Ursus thibetanus G. [Baron] Cuvier, 1823"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ursus thibetanus G. [Baron] Cuvier, 1823"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ursus thibetanus G. [Baron] Cuvier, 1823"`: Animalia->Chordata->Mammalia->Carnivora->Ursidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Viverra civettina Blyth, 1862"`: Animalia
++ Re-using ancestor for `"Viverra civettina Blyth, 1862"`: Animalia->Chordata
++ Re-using ancestor for `"Viverra civettina Blyth, 1862"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Viverra civettina Blyth, 1862"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Viverra civettina Blyth, 1862"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes bengalensis (Shaw, 1800)"`: Animalia
++ Re-using ancestor for `"Vulpes bengalensis (Shaw, 1800)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes bengalensis (Shaw, 1800)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes bengalensis (Shaw, 1800)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes bengalensis (Shaw, 1800)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes cana Blanford, 1877"`: Animalia
++ Re-using ancestor for `"Vulpes cana Blanford, 1877"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes cana Blanford, 1877"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes cana Blanford, 1877"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes cana Blanford, 1877"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes corsac (Linnaeus, 1768)"`: Animalia
++ Re-using ancestor for `"Vulpes corsac (Linnaeus, 1768)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes corsac (Linnaeus, 1768)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes corsac (Linnaeus, 1768)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes corsac (Linnaeus, 1768)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes pallida (Cretzschmar, 1826)"`: Animalia
++ Re-using ancestor for `"Vulpes pallida (Cretzschmar, 1826)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes pallida (Cretzschmar, 1826)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes pallida (Cretzschmar, 1826)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes pallida (Cretzschmar, 1826)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes rueppellii (Schinz, 1825)"`: Animalia
++ Re-using ancestor for `"Vulpes rueppellii (Schinz, 1825)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes rueppellii (Schinz, 1825)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes rueppellii (Schinz, 1825)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes rueppellii (Schinz, 1825)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes velox (Say, 1823)"`: Animalia
++ Re-using ancestor for `"Vulpes velox (Say, 1823)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes velox (Say, 1823)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes velox (Say, 1823)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes velox (Say, 1823)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes chama (A. Smith, 1833)"`: Animalia
++ Re-using ancestor for `"Vulpes chama (A. Smith, 1833)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes chama (A. Smith, 1833)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes chama (A. Smith, 1833)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes chama (A. Smith, 1833)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes ferrilata Hodgson, 1842"`: Animalia
++ Re-using ancestor for `"Vulpes ferrilata Hodgson, 1842"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes ferrilata Hodgson, 1842"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes ferrilata Hodgson, 1842"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes ferrilata Hodgson, 1842"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes vulpes (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Vulpes vulpes (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes vulpes (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes vulpes (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes vulpes (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Bassariscus sumichrasti (Saussure, 1860)"`: Animalia
++ Re-using ancestor for `"Bassariscus sumichrasti (Saussure, 1860)"`: Animalia->Chordata
++ Re-using ancestor for `"Bassariscus sumichrasti (Saussure, 1860)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Bassariscus sumichrasti (Saussure, 1860)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Bassariscus sumichrasti (Saussure, 1860)"`: Animalia->Chordata->Mammalia->Carnivora->Procyonidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Bdeogale jacksoni (Thomas, 1894)"`: Animalia
++ Re-using ancestor for `"Bdeogale jacksoni (Thomas, 1894)"`: Animalia->Chordata
++ Re-using ancestor for `"Bdeogale jacksoni (Thomas, 1894)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Bdeogale jacksoni (Thomas, 1894)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Bdeogale jacksoni (Thomas, 1894)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes foina (Erxleben, 1777)"`: Animalia
++ Re-using ancestor for `"Martes foina (Erxleben, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Martes foina (Erxleben, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes foina (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes foina (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Meles meles (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Meles meles (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Meles meles (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Meles meles (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Meles meles (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela erminea Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Mustela erminea Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela erminea Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela erminea Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela erminea Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela eversmanii Lesson, 1827"`: Animalia
++ Re-using ancestor for `"Mustela eversmanii Lesson, 1827"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela eversmanii Lesson, 1827"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela eversmanii Lesson, 1827"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela eversmanii Lesson, 1827"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vormela peregusna (GÌ_ldenstÌ_dt, 1770)"`: Animalia
++ Re-using ancestor for `"Vormela peregusna (GÌ_ldenstÌ_dt, 1770)"`: Animalia->Chordata
++ Re-using ancestor for `"Vormela peregusna (GÌ_ldenstÌ_dt, 1770)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vormela peregusna (GÌ_ldenstÌ_dt, 1770)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vormela peregusna (GÌ_ldenstÌ_dt, 1770)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Callorhinus ursinus (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Callorhinus ursinus (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Callorhinus ursinus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Callorhinus ursinus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Callorhinus ursinus (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis aureus Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Canis aureus Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Canis aureus Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis aureus Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis aureus Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis latrans Say, 1823"`: Animalia
++ Re-using ancestor for `"Canis latrans Say, 1823"`: Animalia->Chordata
++ Re-using ancestor for `"Canis latrans Say, 1823"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis latrans Say, 1823"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis latrans Say, 1823"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis lupus Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Canis lupus Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Canis lupus Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis lupus Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis lupus Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis rufus Audubon & Bachman, 1851"`: Animalia
++ Re-using ancestor for `"Canis rufus Audubon & Bachman, 1851"`: Animalia->Chordata
++ Re-using ancestor for `"Canis rufus Audubon & Bachman, 1851"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis rufus Audubon & Bachman, 1851"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis rufus Audubon & Bachman, 1851"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis simensis RÌ_ppell, 1840"`: Animalia
++ Re-using ancestor for `"Canis simensis RÌ_ppell, 1840"`: Animalia->Chordata
++ Re-using ancestor for `"Canis simensis RÌ_ppell, 1840"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis simensis RÌ_ppell, 1840"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis simensis RÌ_ppell, 1840"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis adustus Sundevall, 1847"`: Animalia
++ Re-using ancestor for `"Canis adustus Sundevall, 1847"`: Animalia->Chordata
++ Re-using ancestor for `"Canis adustus Sundevall, 1847"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis adustus Sundevall, 1847"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis adustus Sundevall, 1847"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis mesomelas Schreber, 1775"`: Animalia
++ Re-using ancestor for `"Canis mesomelas Schreber, 1775"`: Animalia->Chordata
++ Re-using ancestor for `"Canis mesomelas Schreber, 1775"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis mesomelas Schreber, 1775"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis mesomelas Schreber, 1775"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Caracal caracal (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Caracal caracal (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Caracal caracal (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Caracal caracal (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Caracal caracal (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Galidia elegans I. Geoffroy Saint-Hilaire, 1837"`: Animalia
++ Re-using ancestor for `"Galidia elegans I. Geoffroy Saint-Hilaire, 1837"`: Animalia->Chordata
++ Re-using ancestor for `"Galidia elegans I. Geoffroy Saint-Hilaire, 1837"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Galidia elegans I. Geoffroy Saint-Hilaire, 1837"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Galidia elegans I. Geoffroy Saint-Hilaire, 1837"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Eupleres major Lavauden, 1929"`: Animalia
++ Re-using ancestor for `"Eupleres major Lavauden, 1929"`: Animalia->Chordata
++ Re-using ancestor for `"Eupleres major Lavauden, 1929"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Eupleres major Lavauden, 1929"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Eupleres major Lavauden, 1929"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Catopuma badia (Gray, 1874)"`: Animalia
++ Re-using ancestor for `"Catopuma badia (Gray, 1874)"`: Animalia->Chordata
++ Re-using ancestor for `"Catopuma badia (Gray, 1874)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Catopuma badia (Gray, 1874)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Catopuma badia (Gray, 1874)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Catopuma temminckii (Vigors & Horsfield, 1827)"`: Animalia
++ Re-using ancestor for `"Catopuma temminckii (Vigors & Horsfield, 1827)"`: Animalia->Chordata
++ Re-using ancestor for `"Catopuma temminckii (Vigors & Horsfield, 1827)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Catopuma temminckii (Vigors & Horsfield, 1827)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Catopuma temminckii (Vigors & Horsfield, 1827)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neovison macrodon (Prentis, 1903)"`: Animalia
++ Re-using ancestor for `"Neovison macrodon (Prentis, 1903)"`: Animalia->Chordata
++ Re-using ancestor for `"Neovison macrodon (Prentis, 1903)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neovison macrodon (Prentis, 1903)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neovison macrodon (Prentis, 1903)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. virgata (Illiger, 1815)"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. virgata (Illiger, 1815)"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. virgata (Illiger, 1815)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. virgata (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. virgata (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Canis lupus ssp. dingo Meyer, 1793"`: Animalia
++ Re-using ancestor for `"Canis lupus ssp. dingo Meyer, 1793"`: Animalia->Chordata
++ Re-using ancestor for `"Canis lupus ssp. dingo Meyer, 1793"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Canis lupus ssp. dingo Meyer, 1793"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Canis lupus ssp. dingo Meyer, 1793"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pseudalopex fulvipes (Martin, 1837)"`: Animalia
++ Re-using ancestor for `"Pseudalopex fulvipes (Martin, 1837)"`: Animalia->Chordata
++ Re-using ancestor for `"Pseudalopex fulvipes (Martin, 1837)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pseudalopex fulvipes (Martin, 1837)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pseudalopex fulvipes (Martin, 1837)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes macrotis Merriam, 1888"`: Animalia
++ Re-using ancestor for `"Vulpes macrotis Merriam, 1888"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes macrotis Merriam, 1888"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes macrotis Merriam, 1888"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes macrotis Merriam, 1888"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.4ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes zerda (Zimmermann, 1780)"`: Animalia
++ Re-using ancestor for `"Vulpes zerda (Zimmermann, 1780)"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes zerda (Zimmermann, 1780)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes zerda (Zimmermann, 1780)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes zerda (Zimmermann, 1780)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Nandinia binotata (Gray, 1830)"`: Animalia
++ Re-using ancestor for `"Nandinia binotata (Gray, 1830)"`: Animalia->Chordata
++ Re-using ancestor for `"Nandinia binotata (Gray, 1830)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Nandinia binotata (Gray, 1830)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Nandiniidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Nandiniidae", :verbatim=>"Nandiniidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Nandiniidae -> ["Nandinia binotata (Gray, 1830)"]
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Atilax paludinosus (G.[Baron] Cuvier, 1829)"`: Animalia
++ Re-using ancestor for `"Atilax paludinosus (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata
++ Re-using ancestor for `"Atilax paludinosus (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Atilax paludinosus (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Atilax paludinosus (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Bdeogale crassicauda Peters, 1852"`: Animalia
++ Re-using ancestor for `"Bdeogale crassicauda Peters, 1852"`: Animalia->Chordata
++ Re-using ancestor for `"Bdeogale crassicauda Peters, 1852"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Bdeogale crassicauda Peters, 1852"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Bdeogale crassicauda Peters, 1852"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Bdeogale nigripes Pucheran, 1855"`: Animalia
++ Re-using ancestor for `"Bdeogale nigripes Pucheran, 1855"`: Animalia->Chordata
++ Re-using ancestor for `"Bdeogale nigripes Pucheran, 1855"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Bdeogale nigripes Pucheran, 1855"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Bdeogale nigripes Pucheran, 1855"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Crossarchus alexandri Thomas & Wroughton, 1907"`: Animalia
++ Re-using ancestor for `"Crossarchus alexandri Thomas & Wroughton, 1907"`: Animalia->Chordata
++ Re-using ancestor for `"Crossarchus alexandri Thomas & Wroughton, 1907"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Crossarchus alexandri Thomas & Wroughton, 1907"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Crossarchus alexandri Thomas & Wroughton, 1907"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Crossarchus ansorgei Thomas, 1910"`: Animalia
++ Re-using ancestor for `"Crossarchus ansorgei Thomas, 1910"`: Animalia->Chordata
++ Re-using ancestor for `"Crossarchus ansorgei Thomas, 1910"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Crossarchus ansorgei Thomas, 1910"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Crossarchus ansorgei Thomas, 1910"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Crossarchus obscurus F.G. Cuvier, 1825"`: Animalia
++ Re-using ancestor for `"Crossarchus obscurus F.G. Cuvier, 1825"`: Animalia->Chordata
++ Re-using ancestor for `"Crossarchus obscurus F.G. Cuvier, 1825"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Crossarchus obscurus F.G. Cuvier, 1825"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Crossarchus obscurus F.G. Cuvier, 1825"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Crossarchus platycephalus Goldman, 1984"`: Animalia
++ Re-using ancestor for `"Crossarchus platycephalus Goldman, 1984"`: Animalia->Chordata
++ Re-using ancestor for `"Crossarchus platycephalus Goldman, 1984"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Crossarchus platycephalus Goldman, 1984"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Crossarchus platycephalus Goldman, 1984"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Cynictis penicillata (G.[Baron] Cuvier, 1829)"`: Animalia
++ Re-using ancestor for `"Cynictis penicillata (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata
++ Re-using ancestor for `"Cynictis penicillata (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Cynictis penicillata (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Cynictis penicillata (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Dologale dybowskii (Pousargues, 1893)"`: Animalia
++ Re-using ancestor for `"Dologale dybowskii (Pousargues, 1893)"`: Animalia->Chordata
++ Re-using ancestor for `"Dologale dybowskii (Pousargues, 1893)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Dologale dybowskii (Pousargues, 1893)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Dologale dybowskii (Pousargues, 1893)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes flavescens Bocage, 1889"`: Animalia
++ Re-using ancestor for `"Herpestes flavescens Bocage, 1889"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes flavescens Bocage, 1889"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes flavescens Bocage, 1889"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes flavescens Bocage, 1889"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes pulverulentus (Wagner, 1839)"`: Animalia
++ Re-using ancestor for `"Herpestes pulverulentus (Wagner, 1839)"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes pulverulentus (Wagner, 1839)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes pulverulentus (Wagner, 1839)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes pulverulentus (Wagner, 1839)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes ochraceus (J.E. Gray, 1848)"`: Animalia
++ Re-using ancestor for `"Herpestes ochraceus (J.E. Gray, 1848)"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes ochraceus (J.E. Gray, 1848)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes ochraceus (J.E. Gray, 1848)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes ochraceus (J.E. Gray, 1848)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes sanguineus (RÌ_ppell, 1835)"`: Animalia
++ Re-using ancestor for `"Herpestes sanguineus (RÌ_ppell, 1835)"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes sanguineus (RÌ_ppell, 1835)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes sanguineus (RÌ_ppell, 1835)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes sanguineus (RÌ_ppell, 1835)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Helogale hirtula Thomas, 1904"`: Animalia
++ Re-using ancestor for `"Helogale hirtula Thomas, 1904"`: Animalia->Chordata
++ Re-using ancestor for `"Helogale hirtula Thomas, 1904"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Helogale hirtula Thomas, 1904"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Helogale hirtula Thomas, 1904"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Helogale parvula (Sundevall, 1847)"`: Animalia
++ Re-using ancestor for `"Helogale parvula (Sundevall, 1847)"`: Animalia->Chordata
++ Re-using ancestor for `"Helogale parvula (Sundevall, 1847)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Helogale parvula (Sundevall, 1847)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Helogale parvula (Sundevall, 1847)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes brachyurus Gray, 1837"`: Animalia
++ Re-using ancestor for `"Herpestes brachyurus Gray, 1837"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes brachyurus Gray, 1837"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes brachyurus Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes brachyurus Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes edwardsii (Ìä. Geoffroy Saint-Hilaire, 1818)"`: Animalia
++ Re-using ancestor for `"Herpestes edwardsii (Ìä. Geoffroy Saint-Hilaire, 1818)"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes edwardsii (Ìä. Geoffroy Saint-Hilaire, 1818)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes edwardsii (Ìä. Geoffroy Saint-Hilaire, 1818)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes edwardsii (Ìä. Geoffroy Saint-Hilaire, 1818)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes fuscus Waterhouse, 1838"`: Animalia
++ Re-using ancestor for `"Herpestes fuscus Waterhouse, 1838"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes fuscus Waterhouse, 1838"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes fuscus Waterhouse, 1838"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes fuscus Waterhouse, 1838"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes ichneumon (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Herpestes ichneumon (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes ichneumon (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes ichneumon (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes ichneumon (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes naso de Winton, 1901"`: Animalia
++ Re-using ancestor for `"Herpestes naso de Winton, 1901"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes naso de Winton, 1901"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes naso de Winton, 1901"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes naso de Winton, 1901"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes semitorquatus Gray, 1846"`: Animalia
++ Re-using ancestor for `"Herpestes semitorquatus Gray, 1846"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes semitorquatus Gray, 1846"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes semitorquatus Gray, 1846"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes semitorquatus Gray, 1846"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes smithii Gray, 1837"`: Animalia
++ Re-using ancestor for `"Herpestes smithii Gray, 1837"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes smithii Gray, 1837"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes smithii Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes smithii Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes urva (Hodgson, 1836)"`: Animalia
++ Re-using ancestor for `"Herpestes urva (Hodgson, 1836)"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes urva (Hodgson, 1836)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes urva (Hodgson, 1836)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes urva (Hodgson, 1836)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpestes vitticollis Bennett, 1835"`: Animalia
++ Re-using ancestor for `"Herpestes vitticollis Bennett, 1835"`: Animalia->Chordata
++ Re-using ancestor for `"Herpestes vitticollis Bennett, 1835"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpestes vitticollis Bennett, 1835"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpestes vitticollis Bennett, 1835"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ichneumia albicauda (G.[Baron] Cuvier, 1829)"`: Animalia
++ Re-using ancestor for `"Ichneumia albicauda (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata
++ Re-using ancestor for `"Ichneumia albicauda (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ichneumia albicauda (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ichneumia albicauda (G.[Baron] Cuvier, 1829)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mungos mungo (Gmelin, 1788)"`: Animalia
++ Re-using ancestor for `"Mungos mungo (Gmelin, 1788)"`: Animalia->Chordata
++ Re-using ancestor for `"Mungos mungo (Gmelin, 1788)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mungos mungo (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mungos mungo (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Paracynictis selousi (de Winton, 1896)"`: Animalia
++ Re-using ancestor for `"Paracynictis selousi (de Winton, 1896)"`: Animalia->Chordata
++ Re-using ancestor for `"Paracynictis selousi (de Winton, 1896)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Paracynictis selousi (de Winton, 1896)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Paracynictis selousi (de Winton, 1896)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Rhynchogale melleri (Gray, 1865)"`: Animalia
++ Re-using ancestor for `"Rhynchogale melleri (Gray, 1865)"`: Animalia->Chordata
++ Re-using ancestor for `"Rhynchogale melleri (Gray, 1865)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Rhynchogale melleri (Gray, 1865)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Rhynchogale melleri (Gray, 1865)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Suricata suricatta (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Suricata suricatta (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Suricata suricatta (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Suricata suricatta (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Suricata suricatta (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Herpestidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Melogale moschata (Gray, 1831)"`: Animalia
++ Re-using ancestor for `"Melogale moschata (Gray, 1831)"`: Animalia->Chordata
++ Re-using ancestor for `"Melogale moschata (Gray, 1831)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Melogale moschata (Gray, 1831)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Melogale moschata (Gray, 1831)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Melogale personata I. Geoffroy Saint-Hilaire, 1831"`: Animalia
++ Re-using ancestor for `"Melogale personata I. Geoffroy Saint-Hilaire, 1831"`: Animalia->Chordata
++ Re-using ancestor for `"Melogale personata I. Geoffroy Saint-Hilaire, 1831"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Melogale personata I. Geoffroy Saint-Hilaire, 1831"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Melogale personata I. Geoffroy Saint-Hilaire, 1831"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mydaus javanensis (Desmarest, 1820)"`: Animalia
++ Re-using ancestor for `"Mydaus javanensis (Desmarest, 1820)"`: Animalia->Chordata
++ Re-using ancestor for `"Mydaus javanensis (Desmarest, 1820)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mydaus javanensis (Desmarest, 1820)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mydaus javanensis (Desmarest, 1820)"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mellivora capensis (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Mellivora capensis (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Mellivora capensis (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mellivora capensis (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mellivora capensis (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Conepatus chinga (Molina, 1782)"`: Animalia
++ Re-using ancestor for `"Conepatus chinga (Molina, 1782)"`: Animalia->Chordata
++ Re-using ancestor for `"Conepatus chinga (Molina, 1782)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Conepatus chinga (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Conepatus chinga (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Conepatus humboldtii Gray, 1837"`: Animalia
++ Re-using ancestor for `"Conepatus humboldtii Gray, 1837"`: Animalia->Chordata
++ Re-using ancestor for `"Conepatus humboldtii Gray, 1837"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Conepatus humboldtii Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Conepatus humboldtii Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Conepatus leuconotus (Lichtenstein, 1832)"`: Animalia
++ Re-using ancestor for `"Conepatus leuconotus (Lichtenstein, 1832)"`: Animalia->Chordata
++ Re-using ancestor for `"Conepatus leuconotus (Lichtenstein, 1832)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Conepatus leuconotus (Lichtenstein, 1832)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Conepatus leuconotus (Lichtenstein, 1832)"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Conepatus semistriatus (Boddaert, 1785)"`: Animalia
++ Re-using ancestor for `"Conepatus semistriatus (Boddaert, 1785)"`: Animalia->Chordata
++ Re-using ancestor for `"Conepatus semistriatus (Boddaert, 1785)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Conepatus semistriatus (Boddaert, 1785)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Conepatus semistriatus (Boddaert, 1785)"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mephitis macroura Lichtenstein, 1832"`: Animalia
++ Re-using ancestor for `"Mephitis macroura Lichtenstein, 1832"`: Animalia->Chordata
++ Re-using ancestor for `"Mephitis macroura Lichtenstein, 1832"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mephitis macroura Lichtenstein, 1832"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mephitis macroura Lichtenstein, 1832"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mephitis mephitis (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Mephitis mephitis (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Mephitis mephitis (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mephitis mephitis (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mephitis mephitis (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Spilogale putorius (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Spilogale putorius (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Spilogale putorius (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Spilogale putorius (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Spilogale putorius (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Spilogale pygmaea Thomas, 1898"`: Animalia
++ Re-using ancestor for `"Spilogale pygmaea Thomas, 1898"`: Animalia->Chordata
++ Re-using ancestor for `"Spilogale pygmaea Thomas, 1898"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Spilogale pygmaea Thomas, 1898"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Spilogale pygmaea Thomas, 1898"`: Animalia->Chordata->Mammalia->Carnivora->Mephitidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Galictis cuja (Molina, 1782)"`: Animalia
++ Re-using ancestor for `"Galictis cuja (Molina, 1782)"`: Animalia->Chordata
++ Re-using ancestor for `"Galictis cuja (Molina, 1782)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Galictis cuja (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Galictis cuja (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Galictis vittata (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Galictis vittata (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Galictis vittata (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Galictis vittata (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Galictis vittata (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Eira barbara (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Eira barbara (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Eira barbara (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Eira barbara (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Eira barbara (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ictonyx libycus (Hemprich & Ehrenberg, 1833)"`: Animalia
++ Re-using ancestor for `"Ictonyx libycus (Hemprich & Ehrenberg, 1833)"`: Animalia->Chordata
++ Re-using ancestor for `"Ictonyx libycus (Hemprich & Ehrenberg, 1833)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ictonyx libycus (Hemprich & Ehrenberg, 1833)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ictonyx libycus (Hemprich & Ehrenberg, 1833)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ictonyx striatus (Perry, 1810)"`: Animalia
++ Re-using ancestor for `"Ictonyx striatus (Perry, 1810)"`: Animalia->Chordata
++ Re-using ancestor for `"Ictonyx striatus (Perry, 1810)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ictonyx striatus (Perry, 1810)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ictonyx striatus (Perry, 1810)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lyncodon patagonicus (de Blainville, 1842)"`: Animalia
++ Re-using ancestor for `"Lyncodon patagonicus (de Blainville, 1842)"`: Animalia->Chordata
++ Re-using ancestor for `"Lyncodon patagonicus (de Blainville, 1842)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lyncodon patagonicus (de Blainville, 1842)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lyncodon patagonicus (de Blainville, 1842)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes americana (Turton, 1806)"`: Animalia
++ Re-using ancestor for `"Martes americana (Turton, 1806)"`: Animalia->Chordata
++ Re-using ancestor for `"Martes americana (Turton, 1806)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes americana (Turton, 1806)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes americana (Turton, 1806)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes flavigula (Boddaert, 1785)"`: Animalia
++ Re-using ancestor for `"Martes flavigula (Boddaert, 1785)"`: Animalia->Chordata
++ Re-using ancestor for `"Martes flavigula (Boddaert, 1785)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes flavigula (Boddaert, 1785)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes flavigula (Boddaert, 1785)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes melampus (Wagner, 1840)"`: Animalia
++ Re-using ancestor for `"Martes melampus (Wagner, 1840)"`: Animalia->Chordata
++ Re-using ancestor for `"Martes melampus (Wagner, 1840)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes melampus (Wagner, 1840)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes melampus (Wagner, 1840)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes pennanti (Erxleben, 1777)"`: Animalia
++ Re-using ancestor for `"Martes pennanti (Erxleben, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Martes pennanti (Erxleben, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes pennanti (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes pennanti (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Martes zibellina (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Martes zibellina (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Martes zibellina (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Martes zibellina (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Martes zibellina (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela altaica Pallas, 1811"`: Animalia
++ Re-using ancestor for `"Mustela altaica Pallas, 1811"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela altaica Pallas, 1811"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela altaica Pallas, 1811"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela altaica Pallas, 1811"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela frenata Lichtenstein, 1831"`: Animalia
++ Re-using ancestor for `"Mustela frenata Lichtenstein, 1831"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela frenata Lichtenstein, 1831"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela frenata Lichtenstein, 1831"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela frenata Lichtenstein, 1831"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela kathiah Hodgson, 1835"`: Animalia
++ Re-using ancestor for `"Mustela kathiah Hodgson, 1835"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela kathiah Hodgson, 1835"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela kathiah Hodgson, 1835"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela kathiah Hodgson, 1835"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela itatsi Temminck, 1844"`: Animalia
++ Re-using ancestor for `"Mustela itatsi Temminck, 1844"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela itatsi Temminck, 1844"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela itatsi Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela itatsi Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela nudipes Desmarest, 1822"`: Animalia
++ Re-using ancestor for `"Mustela nudipes Desmarest, 1822"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela nudipes Desmarest, 1822"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela nudipes Desmarest, 1822"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela nudipes Desmarest, 1822"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela putorius Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Mustela putorius Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela putorius Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela putorius Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela putorius Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela sibirica Pallas, 1773"`: Animalia
++ Re-using ancestor for `"Mustela sibirica Pallas, 1773"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela sibirica Pallas, 1773"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela sibirica Pallas, 1773"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela sibirica Pallas, 1773"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Mustela subpalmata Hemprich & Ehrenberg, 1833"`: Animalia
++ Re-using ancestor for `"Mustela subpalmata Hemprich & Ehrenberg, 1833"`: Animalia->Chordata
++ Re-using ancestor for `"Mustela subpalmata Hemprich & Ehrenberg, 1833"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Mustela subpalmata Hemprich & Ehrenberg, 1833"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Mustela subpalmata Hemprich & Ehrenberg, 1833"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Neovison vison (Schreber, 1777)"`: Animalia
++ Re-using ancestor for `"Neovison vison (Schreber, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Neovison vison (Schreber, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Neovison vison (Schreber, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Neovison vison (Schreber, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Poecilogale albinucha (Gray, 1864)"`: Animalia
++ Re-using ancestor for `"Poecilogale albinucha (Gray, 1864)"`: Animalia->Chordata
++ Re-using ancestor for `"Poecilogale albinucha (Gray, 1864)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Poecilogale albinucha (Gray, 1864)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Poecilogale albinucha (Gray, 1864)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Taxidea taxus (Schreber, 1777)"`: Animalia
++ Re-using ancestor for `"Taxidea taxus (Schreber, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Taxidea taxus (Schreber, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Taxidea taxus (Schreber, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Taxidea taxus (Schreber, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctocephalus forsteri (Lesson, 1828)"`: Animalia
++ Re-using ancestor for `"Arctocephalus forsteri (Lesson, 1828)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctocephalus forsteri (Lesson, 1828)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctocephalus forsteri (Lesson, 1828)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctocephalus forsteri (Lesson, 1828)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Otaria byronia (de Blainville, 1820)"`: Animalia
++ Re-using ancestor for `"Otaria byronia (de Blainville, 1820)"`: Animalia->Chordata
++ Re-using ancestor for `"Otaria byronia (de Blainville, 1820)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Otaria byronia (de Blainville, 1820)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Otaria byronia (de Blainville, 1820)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Zalophus californianus (Lesson, 1828)"`: Animalia
++ Re-using ancestor for `"Zalophus californianus (Lesson, 1828)"`: Animalia->Chordata
++ Re-using ancestor for `"Zalophus californianus (Lesson, 1828)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Zalophus californianus (Lesson, 1828)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Zalophus californianus (Lesson, 1828)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Zalophus japonicus (Peters, 1866)"`: Animalia
++ Re-using ancestor for `"Zalophus japonicus (Peters, 1866)"`: Animalia->Chordata
++ Re-using ancestor for `"Zalophus japonicus (Peters, 1866)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Zalophus japonicus (Peters, 1866)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Zalophus japonicus (Peters, 1866)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Zalophus wollebaeki Sivertsen, 1953"`: Animalia
++ Re-using ancestor for `"Zalophus wollebaeki Sivertsen, 1953"`: Animalia->Chordata
++ Re-using ancestor for `"Zalophus wollebaeki Sivertsen, 1953"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Zalophus wollebaeki Sivertsen, 1953"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Zalophus wollebaeki Sivertsen, 1953"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pusa caspica (Gmelin, 1788)"`: Animalia
++ Re-using ancestor for `"Pusa caspica (Gmelin, 1788)"`: Animalia->Chordata
++ Re-using ancestor for `"Pusa caspica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pusa caspica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pusa caspica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Histriophoca fasciata Zimmerman, 1783"`: Animalia
++ Re-using ancestor for `"Histriophoca fasciata Zimmerman, 1783"`: Animalia->Chordata
++ Re-using ancestor for `"Histriophoca fasciata Zimmerman, 1783"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Histriophoca fasciata Zimmerman, 1783"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Histriophoca fasciata Zimmerman, 1783"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pagophilus groenlandicus (Erxleben, 1777)"`: Animalia
++ Re-using ancestor for `"Pagophilus groenlandicus (Erxleben, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Pagophilus groenlandicus (Erxleben, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pagophilus groenlandicus (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pagophilus groenlandicus (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pusa hispida (Schreber, 1775)"`: Animalia
++ Re-using ancestor for `"Pusa hispida (Schreber, 1775)"`: Animalia->Chordata
++ Re-using ancestor for `"Pusa hispida (Schreber, 1775)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pusa hispida (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pusa hispida (Schreber, 1775)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pusa hispida ssp. botnica (Gmelin, 1788)"`: Animalia
++ Re-using ancestor for `"Pusa hispida ssp. botnica (Gmelin, 1788)"`: Animalia->Chordata
++ Re-using ancestor for `"Pusa hispida ssp. botnica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pusa hispida ssp. botnica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pusa hispida ssp. botnica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pusa sibirica (Gmelin, 1788)"`: Animalia
++ Re-using ancestor for `"Pusa sibirica (Gmelin, 1788)"`: Animalia->Chordata
++ Re-using ancestor for `"Pusa sibirica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pusa sibirica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pusa sibirica (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Potos flavus (Schreber, 1774)"`: Animalia
++ Re-using ancestor for `"Potos flavus (Schreber, 1774)"`: Animalia->Chordata
++ Re-using ancestor for `"Potos flavus (Schreber, 1774)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Potos flavus (Schreber, 1774)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Potos flavus (Schreber, 1774)"`: Animalia->Chordata->Mammalia->Carnivora->Procyonidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Bassariscus astutus (Lichtenstein, 1830)"`: Animalia
++ Re-using ancestor for `"Bassariscus astutus (Lichtenstein, 1830)"`: Animalia->Chordata
++ Re-using ancestor for `"Bassariscus astutus (Lichtenstein, 1830)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Bassariscus astutus (Lichtenstein, 1830)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Bassariscus astutus (Lichtenstein, 1830)"`: Animalia->Chordata->Mammalia->Carnivora->Procyonidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. sondaica Temminck, 1844"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. sondaica Temminck, 1844"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. sondaica Temminck, 1844"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. sondaica Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. sondaica Temminck, 1844"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Panthera tigris ssp. balica Schwarz, 1912"`: Animalia
++ Re-using ancestor for `"Panthera tigris ssp. balica Schwarz, 1912"`: Animalia->Chordata
++ Re-using ancestor for `"Panthera tigris ssp. balica Schwarz, 1912"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Panthera tigris ssp. balica Schwarz, 1912"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Panthera tigris ssp. balica Schwarz, 1912"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Nasua narica (Linnaeus, 1766)"`: Animalia
++ Re-using ancestor for `"Nasua narica (Linnaeus, 1766)"`: Animalia->Chordata
++ Re-using ancestor for `"Nasua narica (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Nasua narica (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Nasua narica (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia->Carnivora->Procyonidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Nasua nasua (Linnaeus, 1766)"`: Animalia
++ Re-using ancestor for `"Nasua nasua (Linnaeus, 1766)"`: Animalia->Chordata
++ Re-using ancestor for `"Nasua nasua (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Nasua nasua (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Nasua nasua (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia->Carnivora->Procyonidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Procyon cancrivorus (G.[Baron] Cuvier, 1798)"`: Animalia
++ Re-using ancestor for `"Procyon cancrivorus (G.[Baron] Cuvier, 1798)"`: Animalia->Chordata
++ Re-using ancestor for `"Procyon cancrivorus (G.[Baron] Cuvier, 1798)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Procyon cancrivorus (G.[Baron] Cuvier, 1798)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Procyon cancrivorus (G.[Baron] Cuvier, 1798)"`: Animalia->Chordata->Mammalia->Carnivora->Procyonidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Procyon lotor (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Procyon lotor (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Procyon lotor (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Procyon lotor (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Procyon lotor (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Procyonidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ursus americanus Pallas, 1780"`: Animalia
++ Re-using ancestor for `"Ursus americanus Pallas, 1780"`: Animalia->Chordata
++ Re-using ancestor for `"Ursus americanus Pallas, 1780"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ursus americanus Pallas, 1780"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ursus americanus Pallas, 1780"`: Animalia->Chordata->Mammalia->Carnivora->Ursidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ursus arctos Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Ursus arctos Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Ursus arctos Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ursus arctos Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ursus arctos Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Ursidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Hemigalus derbyanus (Gray, 1837)"`: Animalia
++ Re-using ancestor for `"Hemigalus derbyanus (Gray, 1837)"`: Animalia->Chordata
++ Re-using ancestor for `"Hemigalus derbyanus (Gray, 1837)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Hemigalus derbyanus (Gray, 1837)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Hemigalus derbyanus (Gray, 1837)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctictis binturong (Raffles, 1821)"`: Animalia
++ Re-using ancestor for `"Arctictis binturong (Raffles, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctictis binturong (Raffles, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctictis binturong (Raffles, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctictis binturong (Raffles, 1821)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Arctogalidia trivirgata (Gray, 1832)"`: Animalia
++ Re-using ancestor for `"Arctogalidia trivirgata (Gray, 1832)"`: Animalia->Chordata
++ Re-using ancestor for `"Arctogalidia trivirgata (Gray, 1832)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Arctogalidia trivirgata (Gray, 1832)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Arctogalidia trivirgata (Gray, 1832)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Paguma larvata (C.E.H. Smith, 1827)"`: Animalia
++ Re-using ancestor for `"Paguma larvata (C.E.H. Smith, 1827)"`: Animalia->Chordata
++ Re-using ancestor for `"Paguma larvata (C.E.H. Smith, 1827)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Paguma larvata (C.E.H. Smith, 1827)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Paguma larvata (C.E.H. Smith, 1827)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Paradoxurus hermaphroditus (Pallas, 1777)"`: Animalia
++ Re-using ancestor for `"Paradoxurus hermaphroditus (Pallas, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Paradoxurus hermaphroditus (Pallas, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Paradoxurus hermaphroditus (Pallas, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Paradoxurus hermaphroditus (Pallas, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Paradoxurus zeylonensis (Pallas, 1778)"`: Animalia
++ Re-using ancestor for `"Paradoxurus zeylonensis (Pallas, 1778)"`: Animalia->Chordata
++ Re-using ancestor for `"Paradoxurus zeylonensis (Pallas, 1778)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Paradoxurus zeylonensis (Pallas, 1778)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Paradoxurus zeylonensis (Pallas, 1778)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Civettictis civetta (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Civettictis civetta (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Civettictis civetta (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Civettictis civetta (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Civettictis civetta (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta angolensis Bocage, 1882"`: Animalia
++ Re-using ancestor for `"Genetta angolensis Bocage, 1882"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta angolensis Bocage, 1882"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta angolensis Bocage, 1882"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta angolensis Bocage, 1882"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Melogale orientalis (Horsfield, 1821)"`: Animalia
++ Re-using ancestor for `"Melogale orientalis (Horsfield, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Melogale orientalis (Horsfield, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Melogale orientalis (Horsfield, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Melogale orientalis (Horsfield, 1821)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta genetta (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Genetta genetta (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta genetta (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta genetta (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta genetta (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta maculata (Gray, 1830)"`: Animalia
++ Re-using ancestor for `"Genetta maculata (Gray, 1830)"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta maculata (Gray, 1830)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta maculata (Gray, 1830)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta maculata (Gray, 1830)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta servalina Pucheran, 1855"`: Animalia
++ Re-using ancestor for `"Genetta servalina Pucheran, 1855"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta servalina Pucheran, 1855"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta servalina Pucheran, 1855"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta servalina Pucheran, 1855"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta thierryi Matschie, 1902"`: Animalia
++ Re-using ancestor for `"Genetta thierryi Matschie, 1902"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta thierryi Matschie, 1902"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta thierryi Matschie, 1902"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta thierryi Matschie, 1902"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta tigrina (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Genetta tigrina (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta tigrina (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta tigrina (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta tigrina (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta victoriae Thomas, 1901"`: Animalia
++ Re-using ancestor for `"Genetta victoriae Thomas, 1901"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta victoriae Thomas, 1901"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta victoriae Thomas, 1901"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta victoriae Thomas, 1901"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Poiana richardsonii (Thomson, 1842)"`: Animalia
++ Re-using ancestor for `"Poiana richardsonii (Thomson, 1842)"`: Animalia->Chordata
++ Re-using ancestor for `"Poiana richardsonii (Thomson, 1842)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Poiana richardsonii (Thomson, 1842)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Poiana richardsonii (Thomson, 1842)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionodon linsang (Hardwicke, 1821)"`: Animalia
++ Re-using ancestor for `"Prionodon linsang (Hardwicke, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Prionodon linsang (Hardwicke, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionodon linsang (Hardwicke, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Prionodontidae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Prionodontidae", :verbatim=>"Prionodontidae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Prionodontidae -> ["Prionodon linsang (Hardwicke, 1821)"]
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Prionodon pardicolor Hodgson, 1841"`: Animalia
++ Re-using ancestor for `"Prionodon pardicolor Hodgson, 1841"`: Animalia->Chordata
++ Re-using ancestor for `"Prionodon pardicolor Hodgson, 1841"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Prionodon pardicolor Hodgson, 1841"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Prionodon pardicolor Hodgson, 1841"`: Animalia->Chordata->Mammalia->Carnivora->Prionodontidae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Viverra megaspila Blyth, 1862"`: Animalia
++ Re-using ancestor for `"Viverra megaspila Blyth, 1862"`: Animalia->Chordata
++ Re-using ancestor for `"Viverra megaspila Blyth, 1862"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Viverra megaspila Blyth, 1862"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Viverra megaspila Blyth, 1862"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Viverra tangalunga Gray, 1832"`: Animalia
++ Re-using ancestor for `"Viverra tangalunga Gray, 1832"`: Animalia->Chordata
++ Re-using ancestor for `"Viverra tangalunga Gray, 1832"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Viverra tangalunga Gray, 1832"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Viverra tangalunga Gray, 1832"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.3ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Viverra zibetha Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Viverra zibetha Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Viverra zibetha Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Viverra zibetha Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Viverra zibetha Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Viverricula indica (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia
++ Re-using ancestor for `"Viverricula indica (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata
++ Re-using ancestor for `"Viverricula indica (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Viverricula indica (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Viverricula indica (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Cerdocyon thous (Linnaeus, 1766)"`: Animalia
++ Re-using ancestor for `"Cerdocyon thous (Linnaeus, 1766)"`: Animalia->Chordata
++ Re-using ancestor for `"Cerdocyon thous (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Cerdocyon thous (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Cerdocyon thous (Linnaeus, 1766)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Poiana leightoni Pocock, 1908"`: Animalia
++ Re-using ancestor for `"Poiana leightoni Pocock, 1908"`: Animalia->Chordata
++ Re-using ancestor for `"Poiana leightoni Pocock, 1908"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Poiana leightoni Pocock, 1908"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Poiana leightoni Pocock, 1908"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Aonyx cinereus (Illiger, 1815)"`: Animalia
++ Re-using ancestor for `"Aonyx cinereus (Illiger, 1815)"`: Animalia->Chordata
++ Re-using ancestor for `"Aonyx cinereus (Illiger, 1815)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Aonyx cinereus (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Aonyx cinereus (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Chrotogale owstoni Thomas, 1912"`: Animalia
++ Re-using ancestor for `"Chrotogale owstoni Thomas, 1912"`: Animalia->Chordata
++ Re-using ancestor for `"Chrotogale owstoni Thomas, 1912"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Chrotogale owstoni Thomas, 1912"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Chrotogale owstoni Thomas, 1912"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Chrysocyon brachyurus (Illiger, 1815)"`: Animalia
++ Re-using ancestor for `"Chrysocyon brachyurus (Illiger, 1815)"`: Animalia->Chordata
++ Re-using ancestor for `"Chrysocyon brachyurus (Illiger, 1815)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Chrysocyon brachyurus (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Chrysocyon brachyurus (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Crocuta crocuta (Erxleben, 1777)"`: Animalia
++ Re-using ancestor for `"Crocuta crocuta (Erxleben, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Crocuta crocuta (Erxleben, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Crocuta crocuta (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Crocuta crocuta (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Hyaenidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Cryptoprocta ferox Bennett, 1833"`: Animalia
++ Re-using ancestor for `"Cryptoprocta ferox Bennett, 1833"`: Animalia->Chordata
++ Re-using ancestor for `"Cryptoprocta ferox Bennett, 1833"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Cryptoprocta ferox Bennett, 1833"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Cryptoprocta ferox Bennett, 1833"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Cuon alpinus (Pallas, 1811)"`: Animalia
++ Re-using ancestor for `"Cuon alpinus (Pallas, 1811)"`: Animalia->Chordata
++ Re-using ancestor for `"Cuon alpinus (Pallas, 1811)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Cuon alpinus (Pallas, 1811)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Cuon alpinus (Pallas, 1811)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Felis silvestris Schreber, 1777"`: Animalia
++ Re-using ancestor for `"Felis silvestris Schreber, 1777"`: Animalia->Chordata
++ Re-using ancestor for `"Felis silvestris Schreber, 1777"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Felis silvestris Schreber, 1777"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Felis silvestris Schreber, 1777"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Cynogale bennettii Gray, 1837"`: Animalia
++ Re-using ancestor for `"Cynogale bennettii Gray, 1837"`: Animalia->Chordata
++ Re-using ancestor for `"Cynogale bennettii Gray, 1837"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Cynogale bennettii Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Cynogale bennettii Gray, 1837"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Halichoerus grypus ssp. macrorhynchus Hornschuh & Schilling, 1851"`: Animalia
++ Re-using ancestor for `"Halichoerus grypus ssp. macrorhynchus Hornschuh & Schilling, 1851"`: Animalia->Chordata
++ Re-using ancestor for `"Halichoerus grypus ssp. macrorhynchus Hornschuh & Schilling, 1851"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Halichoerus grypus ssp. macrorhynchus Hornschuh & Schilling, 1851"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Halichoerus grypus ssp. macrorhynchus Hornschuh & Schilling, 1851"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Odobenus rosmarus ssp. divergens (Illiger, 1815)"`: Animalia
++ Re-using ancestor for `"Odobenus rosmarus ssp. divergens (Illiger, 1815)"`: Animalia->Chordata
++ Re-using ancestor for `"Odobenus rosmarus ssp. divergens (Illiger, 1815)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Odobenus rosmarus ssp. divergens (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Odobenus rosmarus ssp. divergens (Illiger, 1815)"`: Animalia->Chordata->Mammalia->Carnivora->Odobenidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Cystophora cristata (Erxleben, 1777)"`: Animalia
++ Re-using ancestor for `"Cystophora cristata (Erxleben, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Cystophora cristata (Erxleben, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Cystophora cristata (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Cystophora cristata (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Diplogale hosei (Thomas, 1892)"`: Animalia
++ Re-using ancestor for `"Diplogale hosei (Thomas, 1892)"`: Animalia->Chordata
++ Re-using ancestor for `"Diplogale hosei (Thomas, 1892)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Diplogale hosei (Thomas, 1892)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Diplogale hosei (Thomas, 1892)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Eupleres goudotii DoyÌ¬re, 1835"`: Animalia
++ Re-using ancestor for `"Eupleres goudotii DoyÌ¬re, 1835"`: Animalia->Chordata
++ Re-using ancestor for `"Eupleres goudotii DoyÌ¬re, 1835"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Eupleres goudotii DoyÌ¬re, 1835"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Eupleres goudotii DoyÌ¬re, 1835"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Lynx lynx ssp. balcanicus Buresh, 1941"`: Animalia
++ Re-using ancestor for `"Lynx lynx ssp. balcanicus Buresh, 1941"`: Animalia->Chordata
++ Re-using ancestor for `"Lynx lynx ssp. balcanicus Buresh, 1941"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Lynx lynx ssp. balcanicus Buresh, 1941"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Lynx lynx ssp. balcanicus Buresh, 1941"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Dusicyon australis (Kerr, 1792)"`: Animalia
++ Re-using ancestor for `"Dusicyon australis (Kerr, 1792)"`: Animalia->Chordata
++ Re-using ancestor for `"Dusicyon australis (Kerr, 1792)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Dusicyon australis (Kerr, 1792)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Dusicyon australis (Kerr, 1792)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Atelocynus microtis (Sclater, 1883)"`: Animalia
++ Re-using ancestor for `"Atelocynus microtis (Sclater, 1883)"`: Animalia->Chordata
++ Re-using ancestor for `"Atelocynus microtis (Sclater, 1883)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Atelocynus microtis (Sclater, 1883)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Atelocynus microtis (Sclater, 1883)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pseudalopex sechurae (Thomas, 1900)"`: Animalia
++ Re-using ancestor for `"Pseudalopex sechurae (Thomas, 1900)"`: Animalia->Chordata
++ Re-using ancestor for `"Pseudalopex sechurae (Thomas, 1900)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pseudalopex sechurae (Thomas, 1900)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pseudalopex sechurae (Thomas, 1900)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pseudalopex vetulus (Lund, 1842)"`: Animalia
++ Re-using ancestor for `"Pseudalopex vetulus (Lund, 1842)"`: Animalia->Chordata
++ Re-using ancestor for `"Pseudalopex vetulus (Lund, 1842)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pseudalopex vetulus (Lund, 1842)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pseudalopex vetulus (Lund, 1842)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pseudalopex griseus (Gray, 1837)"`: Animalia
++ Re-using ancestor for `"Pseudalopex griseus (Gray, 1837)"`: Animalia->Chordata
++ Re-using ancestor for `"Pseudalopex griseus (Gray, 1837)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pseudalopex griseus (Gray, 1837)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pseudalopex griseus (Gray, 1837)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pseudalopex gymnocercus (G. Fischer, 1814)"`: Animalia
++ Re-using ancestor for `"Pseudalopex gymnocercus (G. Fischer, 1814)"`: Animalia->Chordata
++ Re-using ancestor for `"Pseudalopex gymnocercus (G. Fischer, 1814)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pseudalopex gymnocercus (G. Fischer, 1814)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pseudalopex gymnocercus (G. Fischer, 1814)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.2ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Pseudalopex culpaeus (Molina, 1782)"`: Animalia
++ Re-using ancestor for `"Pseudalopex culpaeus (Molina, 1782)"`: Animalia->Chordata
++ Re-using ancestor for `"Pseudalopex culpaeus (Molina, 1782)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Pseudalopex culpaeus (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Pseudalopex culpaeus (Molina, 1782)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ailuropoda melanoleuca (David, 1869)"`: Animalia
++ Re-using ancestor for `"Ailuropoda melanoleuca (David, 1869)"`: Animalia->Chordata
++ Re-using ancestor for `"Ailuropoda melanoleuca (David, 1869)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ailuropoda melanoleuca (David, 1869)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Ailuropoda melanoleuca (David, 1869)"`: Animalia->Chordata->Mammalia->Carnivora->Ursidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Ailurus fulgens F.G. Cuvier, 1825"`: Animalia
++ Re-using ancestor for `"Ailurus fulgens F.G. Cuvier, 1825"`: Animalia->Chordata
++ Re-using ancestor for `"Ailurus fulgens F.G. Cuvier, 1825"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Ailurus fulgens F.G. Cuvier, 1825"`: Animalia->Chordata->Mammalia->Carnivora
++ 1/2) Prepping node model: {:harvest_id=>9, :resource_id=>6, :rank_verbatim=>"family", :parent_resource_pk=>"Carnivora", :resource_pk=>"Ailuridae"}
++ 2/2) Prepping name model: {:resource_id=>6, :harvest_id=>9, :node_resource_pk=>"Ailuridae", :verbatim=>"Ailuridae", :taxonomic_status_verbatim=>"HARVEST ANCESTOR"}
Animalia->Chordata->Mammalia->Carnivora->Ailuridae -> ["Ailurus fulgens F.G. Cuvier, 1825"]
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Enhydra lutris (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Enhydra lutris (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Enhydra lutris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Enhydra lutris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Enhydra lutris (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Erignathus barbatus (Erxleben, 1777)"`: Animalia
++ Re-using ancestor for `"Erignathus barbatus (Erxleben, 1777)"`: Animalia->Chordata
++ Re-using ancestor for `"Erignathus barbatus (Erxleben, 1777)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Erignathus barbatus (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Erignathus barbatus (Erxleben, 1777)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Erignathus barbatus ssp. nauticus (Pallas, 1811)"`: Animalia
++ Re-using ancestor for `"Erignathus barbatus ssp. nauticus (Pallas, 1811)"`: Animalia->Chordata
++ Re-using ancestor for `"Erignathus barbatus ssp. nauticus (Pallas, 1811)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Erignathus barbatus ssp. nauticus (Pallas, 1811)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Erignathus barbatus ssp. nauticus (Pallas, 1811)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Dusicyon avus (Burmeister, 1866)"`: Animalia
++ Re-using ancestor for `"Dusicyon avus (Burmeister, 1866)"`: Animalia->Chordata
++ Re-using ancestor for `"Dusicyon avus (Burmeister, 1866)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Dusicyon avus (Burmeister, 1866)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Dusicyon avus (Burmeister, 1866)"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Eumetopias jubatus (Schreber, 1776)"`: Animalia
++ Re-using ancestor for `"Eumetopias jubatus (Schreber, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Eumetopias jubatus (Schreber, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Eumetopias jubatus (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Eumetopias jubatus (Schreber, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Otariidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Felis bieti Milne-Edwards, 1892"`: Animalia
++ Re-using ancestor for `"Felis bieti Milne-Edwards, 1892"`: Animalia->Chordata
++ Re-using ancestor for `"Felis bieti Milne-Edwards, 1892"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Felis bieti Milne-Edwards, 1892"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Felis bieti Milne-Edwards, 1892"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Felis chaus Schreber, 1777"`: Animalia
++ Re-using ancestor for `"Felis chaus Schreber, 1777"`: Animalia->Chordata
++ Re-using ancestor for `"Felis chaus Schreber, 1777"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Felis chaus Schreber, 1777"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Felis chaus Schreber, 1777"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Felis margarita Loche, 1858"`: Animalia
++ Re-using ancestor for `"Felis margarita Loche, 1858"`: Animalia->Chordata
++ Re-using ancestor for `"Felis margarita Loche, 1858"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Felis margarita Loche, 1858"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Felis margarita Loche, 1858"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Felis nigripes Burchell, 1824"`: Animalia
++ Re-using ancestor for `"Felis nigripes Burchell, 1824"`: Animalia->Chordata
++ Re-using ancestor for `"Felis nigripes Burchell, 1824"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Felis nigripes Burchell, 1824"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Felis nigripes Burchell, 1824"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Fossa fossana (P.L.S. MÌ_ller, 1776)"`: Animalia
++ Re-using ancestor for `"Fossa fossana (P.L.S. MÌ_ller, 1776)"`: Animalia->Chordata
++ Re-using ancestor for `"Fossa fossana (P.L.S. MÌ_ller, 1776)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Fossa fossana (P.L.S. MÌ_ller, 1776)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Fossa fossana (P.L.S. MÌ_ller, 1776)"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Galidictis fasciata (Gmelin, 1788)"`: Animalia
++ Re-using ancestor for `"Galidictis fasciata (Gmelin, 1788)"`: Animalia->Chordata
++ Re-using ancestor for `"Galidictis fasciata (Gmelin, 1788)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Galidictis fasciata (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Galidictis fasciata (Gmelin, 1788)"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Galidictis grandidieri Wozencraft, 1986"`: Animalia
++ Re-using ancestor for `"Galidictis grandidieri Wozencraft, 1986"`: Animalia->Chordata
++ Re-using ancestor for `"Galidictis grandidieri Wozencraft, 1986"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Galidictis grandidieri Wozencraft, 1986"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Galidictis grandidieri Wozencraft, 1986"`: Animalia->Chordata->Mammalia->Carnivora->Eupleridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Vulpes lagopus Linnaeus, 1758"`: Animalia
++ Re-using ancestor for `"Vulpes lagopus Linnaeus, 1758"`: Animalia->Chordata
++ Re-using ancestor for `"Vulpes lagopus Linnaeus, 1758"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Vulpes lagopus Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Vulpes lagopus Linnaeus, 1758"`: Animalia->Chordata->Mammalia->Carnivora->Canidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta abyssinica (RÌ_ppell, 1836)"`: Animalia
++ Re-using ancestor for `"Genetta abyssinica (RÌ_ppell, 1836)"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta abyssinica (RÌ_ppell, 1836)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta abyssinica (RÌ_ppell, 1836)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta abyssinica (RÌ_ppell, 1836)"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta johnstoni Pocock, 1908"`: Animalia
++ Re-using ancestor for `"Genetta johnstoni Pocock, 1908"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta johnstoni Pocock, 1908"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta johnstoni Pocock, 1908"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta johnstoni Pocock, 1908"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Genetta cristata Hayman in Sanborn, 1940"`: Animalia
++ Re-using ancestor for `"Genetta cristata Hayman in Sanborn, 1940"`: Animalia->Chordata
++ Re-using ancestor for `"Genetta cristata Hayman in Sanborn, 1940"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Genetta cristata Hayman in Sanborn, 1940"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Genetta cristata Hayman in Sanborn, 1940"`: Animalia->Chordata->Mammalia->Carnivora->Viverridae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Gulo gulo (Linnaeus, 1758)"`: Animalia
++ Re-using ancestor for `"Gulo gulo (Linnaeus, 1758)"`: Animalia->Chordata
++ Re-using ancestor for `"Gulo gulo (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Gulo gulo (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Gulo gulo (Linnaeus, 1758)"`: Animalia->Chordata->Mammalia->Carnivora->Mustelidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Halichoerus grypus (Fabricius, 1791)"`: Animalia
++ Re-using ancestor for `"Halichoerus grypus (Fabricius, 1791)"`: Animalia->Chordata
++ Re-using ancestor for `"Halichoerus grypus (Fabricius, 1791)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Halichoerus grypus (Fabricius, 1791)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Halichoerus grypus (Fabricius, 1791)"`: Animalia->Chordata->Mammalia->Carnivora->Phocidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Helarctos malayanus (Raffles, 1821)"`: Animalia
++ Re-using ancestor for `"Helarctos malayanus (Raffles, 1821)"`: Animalia->Chordata
++ Re-using ancestor for `"Helarctos malayanus (Raffles, 1821)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Helarctos malayanus (Raffles, 1821)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Helarctos malayanus (Raffles, 1821)"`: Animalia->Chordata->Mammalia->Carnivora->Ursidae
  License Load (0.1ms)  SELECT id, source_url FROM `licenses`
++ Re-using ancestor for `"Herpailurus yagouaroundi (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia
++ Re-using ancestor for `"Herpailurus yagouaroundi (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata
++ Re-using ancestor for `"Herpailurus yagouaroundi (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata->Mammalia
++ Re-using ancestor for `"Herpailurus yagouaroundi (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata->Mammalia->Carnivora
++ Re-using ancestor for `"Herpailurus yagouaroundi (Ìä. Geoffroy Saint-Hilaire, 1803)"`: Animalia->Chordata->Mammalia->Carnivora->Felidae
[10:13:12.752](infos) Loading occurrences (40) diff file into memory...
   (0.1ms)  BEGIN
  SQL (0.2ms)  INSERT INTO `hlogs` (`harvest_id`, `category`, `message`, `created_at`) VALUES (9, 2, 'Loading occurrences (40) diff file into memory...', '2017-11-06 15:13:12')
   (0.3ms)  COMMIT
   (0.1ms)  BEGIN
   (0.1ms)  COMMIT
