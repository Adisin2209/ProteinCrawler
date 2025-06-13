using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Support.UI;
using SeleniumExtras.WaitHelpers;
using System.IO;
using System.Text.Json;
using SimpleWebScraper;

namespace SimpleWebScraper
{
    public class Program
    {
        public static int total = 0;
        public static int delay = 5;

        

        public static void Main()
        {
            var products = new List<Product>();
            var chromeOptions = new ChromeOptions();

            // --- 1. PORTABLES PROFIL-Setup ---
            string profilePath = Path.Combine(Directory.GetCurrentDirectory(), "ChromeProfile");
            chromeOptions.AddArgument("user-data-dir=" + profilePath);
            chromeOptions.AddArgument("--log-level=3"); 

            // --- 2. DYNAMISCHE MODUS-WAHL ---
            bool profileExistiert = Directory.Exists(Path.Combine(profilePath, "Default"));

            if (!profileExistiert)
            {
                Console.WriteLine("Kein Chrome-Profil gefunden.");
                Console.WriteLine("Gleich startet ein sichtbarer Chrome. Klicke IM BROWSER manuell Datenschutz/Cookie ablehnen und Standort festlegen.");
                Console.WriteLine("Schließe dann Chrome und starte den Scraper erneut!");
                // Kein Headless!
                using (var driver = new ChromeDriver(chromeOptions))
                {
                    driver.Manage().Window.Maximize();
                    driver.Navigate().GoToUrl("https://www.marktguru.de/");
                    Console.WriteLine("Chrome ist jetzt offen. Führe alle gewünschten Einstellungen durch – danach einfach Chrome-Fenster schließen!");
                    // Warte bis der User Chrome schließt (blockiert bis Quit)
                    while (true)
                    {
                        System.Threading.Thread.Sleep(500);
                        try
                        {
                            var test = driver.WindowHandles; // error falls Fenster zu
                        }
                        catch
                        {
                            break;
                        }
                    }
                }
                Console.WriteLine("\nVorgang abgeschlossen. Starte das Programm erneut, um zu scrapen!");
                return; // ENDE
            }

            // --- 3. PROFIL VORHANDEN: Scraping im Headless Mode ---
            Console.WriteLine("Profil gefunden. Scraping läuft headless ...");
            chromeOptions.AddArgument("headless");
            delay = 0;

            
            var driverService = ChromeDriverService.CreateDefaultService();
            driverService.SuppressInitialDiagnosticInformation = true;
            driverService.HideCommandPromptWindow = true;
            using (var driver = new ChromeDriver(driverService,chromeOptions))
            {
                var wait = new WebDriverWait(driver, TimeSpan.FromSeconds(15));
                driver.Manage().Window.Maximize();

                foreach (var prod in productsDB.products)
                {
                    try
                    {
                        Console.WriteLine($"-> Suche '{prod}'...");
                        driver.Navigate().GoToUrl("https://www.marktguru.de/search/" + prod);

                        // Optional: Kurze Wartezeit, falls Seitenübergang nicht instant
                        System.Threading.Thread.Sleep(2000);

                        var productHTMLElements = driver.FindElements(By.CssSelector("li.offer-list-item"));
                        Console.WriteLine($"Gefunden: {productHTMLElements.Count} Produkte...");
                        foreach (var productHTMLElement in productHTMLElements)
                        {
                            string name = "N/A", price = "N/A", laden = "N/A", marke = "N/A";
                            try
                            {
                                name = productHTMLElement.FindElement(By.CssSelector("div.header h3")).Text;
                                try { laden = productHTMLElement.FindElement(By.CssSelector("dd.retailer-name a")).Text.Trim(); } catch { }
                                try { marke = productHTMLElement.FindElement(By.CssSelector("dd.brand a")).Text.Trim(); }
                                catch { try { marke = productHTMLElement.FindElement(By.CssSelector("dd.brand span")).Text.Trim(); } catch { } }
                                try { price = productHTMLElement.FindElement(By.CssSelector("dd.price span.price")).Text.Trim(); }
                                catch { try { price = productHTMLElement.FindElement(By.CssSelector("span.offer-price-v2__price")).Text.Trim(); } catch { } }
                            }
                            catch
                            {
                                Console.WriteLine("Fehler beim Produkt-Element, übersprungen.");
                                continue;
                            }

                            var product = new Product()
                            {
                                Name = name,
                                Price = price,
                                Marke = marke,
                                Laden = laden,
                                Kategorie = prod
                            };
                            products.Add(product);
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"\nFehler beim Scrapen: {ex.GetType().Name}: {ex.Message}");
                    }
                }
            }

            // --- 4. Ausgabe/Export ---
            Console.WriteLine("\n--- Gespeicherte Produkte ---");
            foreach (var p in products)
            {
                Console.WriteLine($"Name: {p.Name,-30} | Preis: {p.Price,-8} | Marke: {p.Marke,-20} | Laden: {p.Laden}");
            }
            File.WriteAllText("products.json", JsonSerializer.Serialize(products, new JsonSerializerOptions { WriteIndented = true }));
            Console.WriteLine("FERTIG! (products.json geschrieben)");
        }
    }
}