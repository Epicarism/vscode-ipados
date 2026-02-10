# Agent: runestone-theme-adapter
**Status:** done
**Tokens:** 9,513
**Cost:** $0.0000
**Time:** 2026-02-10T15:16:00.214Z

## Task
PHASE 2: Create RunestoneThemeAdapter.swift - maps our Theme to Runestone's EditorTheme.

Create file: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift

1. READ FIRST for context:
   - VSCodeiPadOS/VSCodeiPadOS/Models/Theme.swift (understand our Theme struct)
   - Research Runestone's EditorTheme protocol requirements

2. Create VSCodeRunestoneTheme class implementing Runestone's theme protocol:
   - Takes our Theme struct in init
   - Maps all our colors to Runestone's expected properties:
     * font -> UIFont.monospacedSystemFont
     * textColor -> theme.editorForeground
     * gutterBackgroundColor -> theme.sidebarBackground
     * lineNumberColor -> theme.lineNumber
     * selectedLineBackgroundColor -> theme.currentLineHighlight
     * etc.

3. Implement textColor(for highlightName: String) -> UIColor? method:
   - Map Tree-sitter highlight names to our theme colors:
     * 'keyword' -> theme.keyword
     * 'string' -> theme.string
     * 'comment' -> theme.comment
     * 'function' -> theme.function
     * 'type' -> theme.type
     * 'variable' -> theme.variable
     * 'number' -> theme.number

4. Implement fontTraits(for highlightName: String) -> FontTraits:
   - Keywords -> .bold
   - Comments -> .italic

5. Create static helper: RunestoneThemeAdapter.theme(from: Theme) -> EditorTheme

## Response
I'll start by reading our Theme.swift file to understand the structure, then research Runestone's EditorTheme protocol.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Models/Theme.swift"}
>>>END

Now let me search for Runestone's EditorTheme protocol requirements:

>>>TOOL web_search
{"query": "Runestone Swift EditorTheme protocol implementation syntax highlighting", "max_results": 5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone Swift EditorTheme protocol implementation syntax highlighting" (5 results):

1. **Creating a Theme | Documentation - docs.runestone.app**
   https://docs.runestone.app/documentation/runestone/creatingatheme/
   Overview The Theme protocol can be used to customize the appearance of TextView. Runestone does not include any themes by default. However, you can find examples of themes in the example project that is included in Runestone&#x27;s repository on GitHub. Take a look at the documentation of the Theme protocol to get an overview of what aspects of TextView can be customized. Syntax Highlighting Text ...

2. **Runestone - Swift Package Registry**
   https://swiftpackageregistry.com/simonbs/Runestone
   👋 Welcome to Runestone - a performant plain text editor for iOS with code editing features Runestone uses GitHub&#x27;s Tree-sitter to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.

3. **runestone/Package.swift at main · bluescreenFTW/runestone**
   https://github.com/bluescreenFTW/runestone/blob/main/Package.swift
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - bluescreenFTW/runestone

4. **simonbs/Runestone | DeepWiki**
   https://deepwiki.com/simonbs/Runestone
   Syntax Highlighting Runestone uses GitHub&#x27;s Tree-sitter library for parsing code and providing syntax highlighting. This implementation allows for high-performance incremental parsing that only re-parses the portions of code that have changed.

5. **Protocols - Documentation**
   https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/
   Protocols Define requirements that conforming types must implement. A protocol defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be adopted by a class, structure, or enumeration to provide an actual implementation of those requirements.


>>>TOOL web_fetch
{"url": "https://docs.runestone.app/documentation/runestone/creatingatheme/", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/documentation/runestone/creatingatheme/

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 1.11s 
[SCRAPE].. ◆ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.00s 
[COMPLETE] ● https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 1.11s 
[Skip Navigation](https://docs.runestone.app/documentation/runestone/creatingatheme/#main)
Light
Dark
Auto


Let me fetch the Theme protocol documentation directly:

>>>TOOL web_fetch
{"url": "https://docs.runestone.app/documentation/runestone/theme", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/documentation/runestone/theme

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://docs.runestone.app/documentation/runestone/theme           
| ✓ | ⏱: 0.94s 
[SCRAPE].. ◆ https://docs.runestone.app/documentation/runestone/theme           
| ✓ | ⏱: 0.00s 
[COMPLETE] ● https://docs.runestone.app/documentation/runestone/theme           
| ✓ | ⏱: 0.94s 
[Skip Navigation](https://docs.runestone.app/documentation/runestone/theme/#main)
Light
Dark
Auto




>>>TOOL web_search
{"query": "Runestone Theme protocol swift textColor highlightName font gutterBackgroundColor", "max_results": 5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone Theme protocol swift textColor highlightName font gutterBackgroundColor" (5 results):

1. **Creating a Theme | Documentation - docs.runestone.app**
   https://docs.runestone.app/documentation/runestone/creatingatheme/
   Overview The Theme protocol can be used to customize the appearance of TextView. Runestone does not include any themes by default. However, you can find examples of themes in the example project that is included in Runestone&#x27;s repository on GitHub. Take a look at the documentation of the Theme protocol to get an overview of what aspects of TextView can be customized. Syntax Highlighting Text ...

2. **Runestone SwiftUI Example - GitHub**
   https://github.com/rosiebunnybear/RunestoneSwiftUIExample
   Runestone SwiftUI Example This is a SwiftUI implementation of the Runestone text editor example app, demonstrating how to integrate the Runestone framework with SwiftUI.

3. **Runestone - Swift Package Registry**
   https://swiftpackageregistry.com/simonbs/Runestone
   The Runestone framework is used by an app of the same name. The Runestone app is a plain text editor for iPhone and iPad that uses all the features of this framework.

4. **Adding a Theme — Runestone Tutorials | Documentation**
   https://docs.runestone.app/tutorials/runestone/adding-a-theme/
   This tutorial guides you through adding a custom theme to your project. You will add the theme to the TextCompanion app and use it when highlighting code.

5. **RunestoneThemes/README.md at main - GitHub**
   https://github.com/yonihemi/RunestoneThemes/blob/main/README.md
   Either one by one, in Runestone -&gt; Settings -&gt; Editor -&gt; Light/Dark theme -&gt; Import Theme; or Copy files to iCloud Drive/Runestone/Themes. Runestone watches this folder and automatically picks up new themes.


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swi
ft                   | ✓ | ⏱: 1.62s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swi
ft                   | ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swi
ft                   | ✓ | ⏱: 1.66s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTheme%2FTheme.swift)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTheme%2FTheme.swift)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTheme%2FTheme.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[Theme](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme)


/
# Theme.swift
/
Copy path
404 - page not found
The 
main
branch of 
Runestone
does not contain the path 
Sources/Runestone/Theme/Theme.swift.
[Return to the repository overview](https://github.com/simonbs/Runestone)
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 1.47s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 0.04s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 1.51s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)


/
# Runestone
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)


/
# Runestone
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources)  
[Documentation.docc](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Documentation.docc "Documentation.docc") | [Documentation.docc](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Documentation.docc "Documentation.docc") |  |   
[Library](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Library "Library") | [Library](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Library "Library") |  |   
[LineManager](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/LineManager "LineManager") | [LineManager](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/LineManager "LineManager") |  |   
[RedBlackTree](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/RedBlackTree "RedBlackTree") | [RedBlackTree](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/RedBlackTree "RedBlackTree") |  |   
[Resources](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Resources "Resources") | [Resources](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Resources "Resources") |  |   
[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView "TextView") | [TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView "TextView") |  |   
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter "TreeSitter") |  |   
[PrivacyInfo.xcprivacy](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/PrivacyInfo.xcprivacy "PrivacyInfo.xcprivacy") | [PrivacyInfo.xcprivacy](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/PrivacyInfo.xcprivacy "PrivacyInfo.xcprivacy") |  |   
[StringSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/StringSyntaxHighlighter.swift "StringSyntaxHighlighter.swift") | [StringSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/StringSyntaxHighlighter.swift "StringSyntaxHighlighter.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 1.44s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 1.49s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# TextView
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# TextView
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)  
[Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") | [Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") |  |   
[CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") | [CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") |  |   
[Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") | [Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") |  |   
[Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") | [Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") |  |   
[Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") | [Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") |  |   
[Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") | [Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") |  |   
[InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") | [InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") |  |   
[LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") | [LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") |  |   
[Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") | [Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") |  |   
[PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") | [PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") |  |   
[SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") | [SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") |  |   
[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") | [SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") |  |   
[TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") | [TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 1.40s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 1.45s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FAppearance)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FAppearance)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
          * Theme.xcassets
          * DefaultTheme.swift
          * FontTraits.swift
          * HighlightName.swift
          * LineBreakMode.swift
          * LineSelectionDisplayType.swift
          * Theme.swift
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# Appearance
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/Appearance)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/Appearance)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# Appearance
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)  
[Theme.xcassets](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance/Theme.xcassets "Theme.xcassets") | [Theme.xcassets](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance/Theme.xcassets "Theme.xcassets") |  |   
[DefaultTheme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift "DefaultTheme.swift") | [DefaultTheme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift "DefaultTheme.swift") |  |   
[FontTraits.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/FontTraits.swift "FontTraits.swift") | [FontTraits.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/FontTraits.swift "FontTraits.swift") |  |   
[HighlightName.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/HighlightName.swift "HighlightName.swift") | [HighlightName.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/HighlightName.swift "HighlightName.swift") |  |   
[LineBreakMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineBreakMode.swift "LineBreakMode.swift") | [LineBreakMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineBreakMode.swift "LineBreakMode.swift") |  |   
[LineSelectionDisplayType.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineSelectionDisplayType.swift "LineSelectionDisplayType.swift") | [LineSelectionDisplayType.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineSelectionDisplayType.swift "LineSelectionDisplayType.swift") |  |   
[Theme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/Theme.swift "Theme.swift") | [Theme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/Theme.swift "Theme.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/Theme.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/Theme.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...ources/Runestone/TextView/App
earance/Theme.swift  | ✓ | ⏱: 0.61s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...ources/Runestone/TextView/App
earance/Theme.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...ources/Runestone/TextView/App
earance/Theme.swift  | ✓ | ⏱: 0.62s 
```
import UIKit

/// Fonts and colors to be used by a `TextView`.
public protocol Theme: AnyObject {
    /// Default font of text in the text view.
    var font: UIFont { get }
    /// Default color of text in the text view.
    var textColor: UIColor { get }
    /// Background color of the gutter containing line numbers.
    var gutterBackgroundColor: UIColor { get }
    /// Color of the hairline next to the gutter containing line numbers.
    var gutterHairlineColor: UIColor { get }
    /// Width of the hairline next to the gutter containing line numbers.
    var gutterHairlineWidth: CGFloat { get }
    /// Color of the line numbers in the gutter.
    var lineNumberColor: UIColor { get }
    /// Font of the line nubmers in the gutter.
    var lineNumberFont: UIFont { get }
    /// Background color of the selected line.
    var selectedLineBackgroundColor: UIColor { get }
    /// Color of the line number of the selected line.
    var selectedLinesLineNumberColor: UIColor { get }
    /// Background color of the gutter for selected lines.
    var selectedLinesGutterBackgroundColor: UIColor { get }
    /// Color of invisible characters, i.e. dots, spaces and line breaks.
    var invisibleCharactersColor: UIColor { get }
    /// Color of the hairline next to the page guide.
    var pageGuideHairlineColor: UIColor { get }
    /// Width of the hairline next to the page guide.
    var pageGuideHairlineWidth: CGFloat { get }
    /// Background color of the page guide.
    var pageGuideBackgroundColor: UIColor { get }
    /// Background color of marked text. Text will be marked when writing certain languages, for example Chinese and Japanese.
    var markedTextBackgroundColor: UIColor { get }
    /// Corner radius of the background of marked text. Text will be marked when writing certain languages, for example Chinese and Japanese.
    /// A value of zero or less means that the background will not have rounded corners. Defaults to 0.
    var markedTextBackgroundCornerRadius: CGFloat { get }
    /// Color of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func textColor(for highlightName: String) -> UIColor?
    /// Font of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func font(for highlightName: String) -> UIFont?
    /// Traits of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func fontTraits(for highlightName: String) -> FontTraits
    /// Shadow of text matching the capture sequence.
    ///
    /// See <doc:CreatingATheme> for more information on higlight names.
    func shadow(for highlightName: String) -> NSShadow?
    /// Highlighted range for a text range matching a search query.
    ///
    /// This function is called when highlighting a search result that was found using the standard find/replace interaction enabled using <doc:TextView/isFindInteractionEnabled>.
    ///
    /// Return `nil` to prevent highlighting the range.
    /// - Parameters:
    ///   - foundTextRange: The text range matching a search query.
    ///   - style: Style used to decorate the text.
    /// - Returns: The object used for highlighting the provided text range, or `nil` if the range should not be highlighted.
    @available(iOS 16, *)
    func highlightedRange(forFoundTextRange foundTextRange: NSRange, ofStyle style: UITextSearchFoundTextStyle) -> HighlightedRange?
}

public extension Theme {
    var gutterHairlineWidth: CGFloat {
        hairlineLength
    }

    var pageGuideHairlineWidth: CGFloat {
        hairlineLength
    }

    var markedTextBackgroundCornerRadius: CGFloat {
        0
    }

    func font(for highlightName: String) -> UIFont? {
        nil
    }

    func fontTraits(for highlightName: String) -> FontTraits {
        []
    }

    func shadow(for highlightName: String) -> NSShadow? {
        nil
    }

    @available(iOS 16, *)
    func highlightedRange(forFoundTextRange foundTextRange: NSRange, ofStyle style: UITextSearchFoundTextStyle) -> HighlightedRange? {
        switch style {
        case .found:
            return HighlightedRange(range: foundTextRange, color: .systemYellow.withAlphaComponent(0.2))
        case .highlighted:
            return HighlightedRange(range: foundTextRange, color: .systemYellow)
        case .normal:
            return nil
        @unknown default:
            return nil
        }
    }
}

```


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/FontTraits.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/FontTraits.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...s/Runestone/TextView/Appearan
ce/FontTraits.swift  | ✓ | ⏱: 0.56s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...s/Runestone/TextView/Appearan
ce/FontTraits.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...s/Runestone/TextView/Appearan
ce/FontTraits.swift  | ✓ | ⏱: 0.57s 
```
import Foundation

/// Traits to be applied to a font.
///
/// The font traits can be used with a ``Theme`` to change the appearance of the font when syntax highlighting text.
public struct FontTraits: OptionSet {
    /// Attribute creating a bold font.
    public static let bold = Self(rawValue: 1 << 0)
    /// Attribute creating an italic font.
    public static let italic = Self(rawValue: 1 << 1)

    /// The corresponding value of the raw type.
    public let rawValue: Int

    /// Creates a set of font traits.
    /// - Parameter rawValue: The raw vlaue to create the font traits from.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

```


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/HighlightName.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/HighlightName.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...unestone/TextView/Appearance/
HighlightName.swift  | ✓ | ⏱: 0.51s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...unestone/TextView/Appearance/
HighlightName.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...unestone/TextView/Appearance/
HighlightName.swift  | ✓ | ⏱: 0.51s 
```
#if DEBUG
private var previousUnrecognizedHighlightNames: [String] = []
#endif

enum HighlightName: String {
    case comment
    case constantBuiltin = "constant.builtin"
    case constantCharacter = "constant.character"
    case constructor
    case function
    case keyword
    case number
    case `operator`
    case property
    case punctuation
    case string
    case type
    case variable
    case variableBuiltin = "variable.builtin"

    init?(_ rawHighlightName: String) {
        var comps = rawHighlightName.split(separator: ".")
        while !comps.isEmpty {
            let candidateRawHighlightName = comps.joined(separator: ".")
            if let highlightName = Self(rawValue: candidateRawHighlightName) {
                self = highlightName
                return
            }
            comps.removeLast()
        }
#if DEBUG
        if !previousUnrecognizedHighlightNames.contains(rawHighlightName) {
            previousUnrecognizedHighlightNames.append(rawHighlightName)
            print("Unrecognized highlight name: '\(rawHighlightName)'."
                  + " Add the highlight name to HighlightName.swift if you want to add support for syntax highlighting it."
                  + " This message will only be shown once per highlight name.")
        }
#endif
        return nil
    }
}

```


Now let me fetch the DefaultTheme to see an example implementation:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://raw.githubusercontent.com/simonbs/Runest...Runestone/TextView/Appearance
/DefaultTheme.swift  | ✓ | ⏱: 0.53s 
[SCRAPE].. ◆ 
https://raw.githubusercontent.com/simonbs/Runest...Runestone/TextView/Appearance
/DefaultTheme.swift  | ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://raw.githubusercontent.com/simonbs/Runest...Runestone/TextView/Appearance
/DefaultTheme.swift  | ✓ | ⏱: 0.53s 
```
import UIKit

/// Default theme used by Runestone when no other theme has been set.
public final class DefaultTheme: Runestone.Theme {
    public let font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    public let textColor = UIColor(themeColorNamed: "foreground")
    public let gutterBackgroundColor = UIColor(themeColorNamed: "gutter_background")
    public let gutterHairlineColor = UIColor(themeColorNamed: "gutter_hairline")
    public let lineNumberColor = UIColor(themeColorNamed: "line_number")
    public let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    public let selectedLineBackgroundColor = UIColor(themeColorNamed: "current_line")
    public let selectedLinesLineNumberColor = UIColor(themeColorNamed: "line_number_current_line")
    public let selectedLinesGutterBackgroundColor = UIColor(themeColorNamed: "gutter_background")
    public let invisibleCharactersColor = UIColor(themeColorNamed: "invisible_characters")
    public let pageGuideHairlineColor = UIColor(themeColorNamed: "page_guide_hairline")
    public let pageGuideBackgroundColor = UIColor(themeColorNamed: "page_guide_background")
    public let markedTextBackgroundColor = UIColor(themeColorNamed: "marked_text")
    public let selectionColor = UIColor(themeColorNamed: "selection")

    public init() {}

    // swiftlint:disable:next cyclomatic_complexity
    public func textColor(for highlightName: String) -> UIColor? {
        guard let highlightName = HighlightName(highlightName) else {
            return nil
        }
        switch highlightName {
        case .comment:
            return UIColor(themeColorNamed: "comment")
        case .constantBuiltin:
            return UIColor(themeColorNamed: "constant_builtin")
        case .constantCharacter:
            return UIColor(themeColorNamed: "constant_character")
        case .constructor:
            return UIColor(themeColorNamed: "constructor")
        case .function:
            return UIColor(themeColorNamed: "function")
        case .keyword:
            return UIColor(themeColorNamed: "keyword")
        case .number:
            return UIColor(themeColorNamed: "number")
        case .property:
            return UIColor(themeColorNamed: "property")
        case .string:
            return UIColor(themeColorNamed: "string")
        case .type:
            return UIColor(themeColorNamed: "type")
        case .variable:
            return nil
        case .variableBuiltin:
            return UIColor(themeColorNamed: "variable_builtin")
        case .operator:
            return UIColor(themeColorNamed: "operator")
        case .punctuation:
            return UIColor(themeColorNamed: "punctuation")
        }
    }

    public func fontTraits(for highlightName: String) -> FontTraits {
        guard let highlightName = HighlightName(highlightName) else {
            return []
        }
        if highlightName == .keyword {
            return .bold
        } else {
            return []
        }
    }

    @available(iOS 16.0, *)
    public func highlightedRange(forFoundTextRange foundTextRange: NSRange, ofStyle style: UITextSearchFoundTextStyle) -> HighlightedRange? {
        switch style {
        case .found:
            let color = UIColor(themeColorNamed: "search_match_found")
            return HighlightedRange(range: foundTextRange, color: color, cornerRadius: 2)
        case .highlighted:
            let color = UIColor(themeColorNamed: "search_match_highlighted")
            return HighlightedRange(range: foundTextRange, color: color, cornerRadius: 2)
        case .normal:
            return nil
        @unknown default:
            return nil
        }
    }
}

private extension UIColor {
    convenience init(themeColorNamed name: String) {
        self.init(named: "theme_" + name, in: .module, compatibleWith: nil)!
    }
}

```


Now let me check if the Services folder exists in the project structure:

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
📁 Menus/
📁 Models/
📁 Resources/
📁 Services/
📁 Tests/
📁 UITests/
📁 Utils/
📁 Views/
   .tooling_note.txt
   ContentView_shift_arrow.patch
   ContentView.swift
   ContentView.swift.bak
   FIX_SUMMARY.md
   IMPLEMENTATION_SUMMARY.md
   Info.plist
   KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
   KeyboardShortcuts.md
   MULTI_WINDOW_IMPLEMENTATION.md
   MultiWindowSupport.md
   SceneDelegate.swift
   SyntaxHighlighter_Optimizations.md
(cached)


Now I have all the information I need. Let me create the RunestoneThemeAdapter.swift file:

>>>TOOL create_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift", "content": "//\n//  RunestoneThemeAdapter.swift\n//  VSCodeiPadOS\n//\n//  Maps our Theme struct to Runestone's Theme protocol for syntax highlighting\n//\n\nimport UIKit\nimport SwiftUI\nimport Runestone\n\n// MARK: - VSCodeRunestoneTheme\n\n/// A Runestone Theme implementation that adapts our app's Theme struct\n/// to Runestone's expected theme protocol for syntax highlighting.\npublic final class VSCodeRunestoneTheme: Runestone.Theme {\n    \n    // MARK: - Properties\n    \n    private let theme: Models.Theme\n    private let fontSize: CGFloat\n    \n    // MARK: - Required Theme Properties\n    \n    public var font: UIFont {\n        .monospacedSystemFont(ofSize: fontSize, weight: .regular)\n    }\n    \n    public var textColor: UIColor {\n        UIColor(theme.editorForeground)\n    }\n    \n    public var gutterBackgroundColor: UIColor {\n        UIColor(theme.sidebarBackground)\n    }\n    \n    public var gutterHairlineColor: UIColor {\n        UIColor(theme.sidebarBackground).withAlphaComponent(0.5)\n    }\n    \n    public var gutterHairlineWidth: CGFloat {\n        1.0 / UIScreen.main.scale\n    }\n    \n    public var lineNumberColor: UIColor {\n        UIColor(theme.lineNumber)\n    }\n    \n    public var lineNumberFont: UIFont {\n        .monospacedSystemFont(ofSize: fontSize, weight: .regular)\n    }\n    \n    public var selectedLineBackgroundColor: UIColor {\n        UIColor(theme.currentLineHighlight)\n    }\n    \n    public var selectedLinesLineNumberColor: UIColor {\n        UIColor(theme.lineNumberActive)\n    }\n    \n    public var selectedLinesGutterBackgroundColor: UIColor {\n        UIColor(theme.sidebarBackground)\n    }\n    \n    public var invisibleCharactersColor: UIColor {\n        UIColor(theme.lineNumber).withAlphaComponent(0.4)\n    }\n    \n    public var pageGuideHairlineColor: UIColor {\n        UIColor(theme.indentGuide)\n    }\n    \n    public var pageGuideHairlineWidth: CGFloat {\n        1.0 / UIScreen.main.scale\n    }\n    \n    public var pageGuideBackgroundColor: UIColor {\n        UIColor(theme.editorBackground).withAlphaComponent(0.5)\n    }\n    \n    public var markedTextBackgroundColor: UIColor {\n        UIColor(theme.selection)\n    }\n    \n    public var markedTextBackgroundCornerRadius: CGFloat {\n        2.0\n    }\n    \n    // MARK: - Initialization\n    \n    /// Creates a Runestone theme from our app's Theme struct\n    /// - Parameters:\n    ///   - theme: Our app's Theme struct containing colors and styles\n    ///   - fontSize: Font size for editor text (default: 14)\n    public init(theme: Models.Theme, fontSize: CGFloat = 14) {\n        self.theme = theme\n        self.fontSize = fontSize\n    }\n    \n    // MARK: - Syntax Highlighting\n    \n    /// Returns the text color for a given Tree-sitter highlight name\n    /// - Parameter highlightName: The Tree-sitter capture name (e.g., \"keyword\", \"string\")\n    /// - Returns: The UIColor to use for that highlight, or nil for default color\n    public func textColor(for highlightName: String) -> UIColor? {\n        // Handle compound highlight names like \"keyword.return\" by checking prefixes\n        let normalizedName = normalizeHighlightName(highlightName)\n        \n        switch normalizedName {\n        // Keywords (control flow, storage, etc.)\n        case \"keyword\", \"keyword.control\", \"keyword.return\", \"keyword.function\",\n             \"keyword.operator\", \"keyword.import\", \"keyword.storage\", \"keyword.type\":\n            return UIColor(theme.keyword)\n            \n        // Strings and string-like content\n        case \"string\", \"string.special\", \"string.escape\", \"string.regex\":\n            return UIColor(theme.string)\n            \n        // Comments\n        case \"comment\", \"comment.line\", \"comment.block\", \"comment.documentation\":\n            return UIColor(theme.comment)\n            \n        // Functions and method calls\n        case \"function\", \"function.call\", \"function.method\", \"function.builtin\",\n             \"method\", \"method.call\":\n            return UIColor(theme.function)\n            \n        // Types, classes, and type-like constructs\n        case \"type\", \"type.builtin\", \"type.definition\", \"type.qualifier\",\n             \"class\", \"struct\", \"enum\", \"interface\", \"namespace\":\n            return UIColor(theme.type)\n            \n        // Variables and properties\n        case \"variable\", \"variable.parameter\", \"variable.member\",\n             \"property\", \"property.definition\", \"field\":\n            return UIColor(theme.variable)\n            \n        // Variable builtins (self, this, super)\n        case \"variable.builtin\", \"variable.language\":\n            return UIColor(theme.keyword).withAlphaComponent(0.9)\n            \n        // Numbers and numeric constants\n        case \"number\", \"number.float\", \"float\", \"integer\":\n            return UIColor(theme.number)\n            \n        // Constants\n        case \"constant\", \"constant.builtin\", \"constant.character\", \"boolean\":\n            return UIColor(theme.number)\n            \n        // Constructors\n        case \"constructor\":\n            return UIColor(theme.function)\n            \n        // Operators and punctuation\n        case \"operator\":\n            return UIColor(theme.editorForeground)\n            \n        case \"punctuation\", \"punctuation.bracket\", \"punctuation.delimiter\",\n             \"punctuation.special\":\n            return UIColor(theme.editorForeground).withAlphaComponent(0.8)\n            \n        // Tags (HTML/XML)\n        case \"tag\", \"tag.builtin\":\n            return UIColor(theme.keyword)\n            \n        // Attributes\n        case \"attribute\", \"attribute.builtin\":\n            return UIColor(theme.function)\n            \n        // Labels\n        case \"label\":\n            return UIColor(theme.type)\n            \n        // Embedded code (like template literals)\n        case \"embedded\":\n            return UIColor(theme.string)\n            \n        default:\n            // For unrecognized names, try to match by prefix\n            return textColorByPrefix(highlightName)\n        }\n    }\n    \n    /// Attempts to find a color by checking highlight name prefixes\n    private func textColorByPrefix(_ highlightName: String) -> UIColor? {\n        if highlightName.hasPrefix(\"keyword\") {\n            return UIColor(theme.keyword)\n        } else if highlightName.hasPrefix(\"string\") {\n            return UIColor(theme.string)\n        } else if highlightName.hasPrefix(\"comment\") {\n            return UIColor(theme.comment)\n        } else if highlightName.hasPrefix(\"function\") || highlightName.hasPrefix(\"method\") {\n            return UIColor(theme.function)\n        } else if highlightName.hasPrefix(\"type\") || highlightName.hasPrefix(\"class\") {\n            return UIColor(theme.type)\n        } else if highlightName.hasPrefix(\"variable\") || highlightName.hasPrefix(\"property\") {\n            return UIColor(theme.variable)\n        } else if highlightName.hasPrefix(\"number\") || highlightName.hasPrefix(\"constant\") {\n            return UIColor(theme.number)\n        }\n        return nil\n    }\n    \n    /// Normalizes a highlight name by converting it to lowercase and trimming whitespace\n    private func normalizeHighlightName(_ name: String) -> String {\n        name.lowercased().trimmingCharacters(in: .whitespaces)\n    }\n    \n    /// Returns the font for a given highlight name (optional override)\n    /// - Parameter highlightName: The Tree-sitter capture name\n    /// - Returns: A custom font, or nil to use the default font\n    public func font(for highlightName: String) -> UIFont? {\n        // Use default font for all highlights - traits will modify it\n        return nil\n    }\n    \n    /// Returns font traits (bold, italic) for a given highlight name\n    /// - Parameter highlightName: The Tree-sitter capture name\n    /// - Returns: FontTraits to apply to the text\n    public func fontTraits(for highlightName: String) -> FontTraits {\n        let normalizedName = normalizeHighlightName(highlightName)\n        \n        switch normalizedName {\n        // Keywords are bold\n        case let name where name.hasPrefix(\"keyword\"):\n            return .bold\n            \n        // Comments are italic\n        case let name where name.hasPrefix(\"comment\"):\n            return .italic\n            \n        // Type definitions can be bold\n        case \"type.definition\", \"class\", \"struct\", \"enum\", \"interface\":\n            return .bold\n            \n        // Storage modifiers (static, const, etc.) are italic\n        case \"storage\", \"storage.modifier\":\n            return .italic\n            \n        default:\n            return []\n        }\n    }\n    \n    /// Returns a shadow for a given highlight name (optional)\n    /// - Parameter highlightName: The Tree-sitter capture name\n    /// - Returns: An NSShadow to apply, or nil for no shadow\n    public func shadow(for highlightName: String) -> NSShadow? {\n        // No shadows by default - can be customized if needed\n        return nil\n    }\n    \n    /// Returns highlighted range styling for search results (iOS 16+)\n    @available(iOS 16.0, *)\n    public func highlightedRange(\n        forFoundTextRange foundTextRange: NSRange,\n        ofStyle style: UITextSearchFoundTextStyle\n    ) -> HighlightedRange? {\n        switch style {\n        case .found:\n            // Background for all matches\n            return HighlightedRange(\n                range: foundTextRange,\n                color: UIColor(theme.selection).withAlphaComponent(0.4),\n                cornerRadius: 2\n            )\n        case .highlighted:\n            // Background for the current/active match\n            return HighlightedRange(\n                range: foundTextRange,\n                color: UIColor(theme.selection),\n                cornerRadius: 2\n            )\n        case .normal:\n            return nil\n        @unknown default:\n            return nil\n        }\n    }\n}\n\n// MARK: - RunestoneThemeAdapter\n\n/// Static helper for creating Runestone themes from our app's Theme struct\npublic enum RunestoneThemeAdapter {\n    \n    /// Creates a Runestone Theme from our app's Theme struct\n    /// - Parameters:\n    ///   - theme: The app's Theme to convert\n    ///   - fontSize: Font size for the editor (default: 14)\n    /// - Returns: A Runestone-compatible Theme\n    public static func theme(from theme: Models.Theme, fontSize: CGFloat = 14) -> Runestone.Theme {\n        VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)\n    }\n    \n    /// Creates a Runestone Theme from our app's Theme with customized settings\n    /// - Parameters:\n    ///   - theme: The app's Theme to convert\n    ///   - fontSize: Font size for the editor\n    /// - Returns: A VSCodeRunestoneTheme instance\n    public static func createTheme(\n        from theme: Models.Theme,\n        fontSize: CGFloat = 14\n    ) -> VSCodeRunestoneTheme {\n        VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)\n    }\n}\n\n// MARK: - Theme Namespace Alias\n\n/// Namespace alias to avoid conflicts between our Theme model and Runestone's Theme protocol\npublic enum Models {\n    public typealias Theme = VSCodeiPadOS.Theme\n}\n"}
>>>END

---

## 🔧 TOOL RESULTS

[create_file]
✅ Created: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift


Now let me verify the file was created correctly and check if there are any namespace issues:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift", "start_line": 1, "end_line": 50}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift (lines 2-50 of 315)
────────────────────────────────────────
2: //  RunestoneThemeAdapter.swift
3: //  VSCodeiPadOS
4: //
5: //  Maps our Theme struct to Runestone's Theme protocol for syntax highlighting
6: //
7: 
8: import UIKit
9: import SwiftUI
10: import Runestone
11: 
12: // MARK: - VSCodeRunestoneTheme
13: 
14: /// A Runestone Theme implementation that adapts our app's Theme struct
15: /// to Runestone's expected theme protocol for syntax highlighting.
16: public final class VSCodeRunestoneTheme: Runestone.Theme {
17:     
18:     // MARK: - Properties
19:     
20:     private let theme: Models.Theme
21:     private let fontSize: CGFloat
22:     
23:     // MARK: - Required Theme Properties
24:     
25:     public var font: UIFont {
26:         .monospacedSystemFont(ofSize: fontSize, weight: .regular)
27:     }
28:     
29:     public var textColor: UIColor {
30:         UIColor(theme.editorForeground)
31:     }
32:     
33:     public var gutterBackgroundColor: UIColor {
34:         UIColor(theme.sidebarBackground)
35:     }
36:     
37:     public var gutterHairlineColor: UIColor {
38:         UIColor(theme.sidebarBackground).withAlphaComponent(0.5)
39:     }
40:     
41:     public var gutterHairlineWidth: CGFloat {
42:         1.0 / UIScreen.main.scale
43:     }
44:     
45:     public var lineNumberColor: UIColor {
46:         UIColor(theme.lineNumber)
47:     }
48:     
49:     public var lineNumberFont: UIFont {
50:         .monospacedSystemFont(ofSize: fontSize, weight: .regular)




Let me verify the complete file was created:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift", "start_line": 50, "end_line": 150}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift (lines 51-150 of 315)
────────────────────────────────────────
51:     }
52:     
53:     public var selectedLineBackgroundColor: UIColor {
54:         UIColor(theme.currentLineHighlight)
55:     }
56:     
57:     public var selectedLinesLineNumberColor: UIColor {
58:         UIColor(theme.lineNumberActive)
59:     }
60:     
61:     public var selectedLinesGutterBackgroundColor: UIColor {
62:         UIColor(theme.sidebarBackground)
63:     }
64:     
65:     public var invisibleCharactersColor: UIColor {
66:         UIColor(theme.lineNumber).withAlphaComponent(0.4)
67:     }
68:     
69:     public var pageGuideHairlineColor: UIColor {
70:         UIColor(theme.indentGuide)
71:     }
72:     
73:     public var pageGuideHairlineWidth: CGFloat {
74:         1.0 / UIScreen.main.scale
75:     }
76:     
77:     public var pageGuideBackgroundColor: UIColor {
78:         UIColor(theme.editorBackground).withAlphaComponent(0.5)
79:     }
80:     
81:     public var markedTextBackgroundColor: UIColor {
82:         UIColor(theme.selection)
83:     }
84:     
85:     public var markedTextBackgroundCornerRadius: CGFloat {
86:         2.0
87:     }
88:     
89:     // MARK: - Initialization
90:     
91:     /// Creates a Runestone theme from our app's Theme struct
92:     /// - Parameters:
93:     ///   - theme: Our app's Theme struct containing colors and styles
94:     ///   - fontSize: Font size for editor text (default: 14)
95:     public init(theme: Models.Theme, fontSize: CGFloat = 14) {
96:         self.theme = theme
97:         self.fontSize = fontSize
98:     }
99:     
100:     // MARK: - Syntax Highlighting
101:     
102:     /// Returns the text color for a given Tree-sitter highlight name
103:     /// - Parameter highlightName: The Tree-sitter capture name (e.g., "keyword", "string")
104:     /// - Returns: The UIColor to use for that highlight, or nil for default color
105:     public func textColor(for highlightName: String) -> UIColor? {
106:         // Handle compound highlight names like "keyword.return" by checking prefixes
107:         let normalizedName = normalizeHighlightName(highlightName)
108:         
109:         switch normalizedName {
110:         // Keywords (control flow, storage, etc.)
111:         case "keyword", "keyword.control", "keyword.return", "keyword.function",
112:              "keyword.operator", "keyword.import", "keyword.storage", "keyword.type":
113:             return UIColor(theme.keyword)
114:             
115:         // Strings and string-like content
116:         case "string", "string.special", "string.escape", "string.regex":
117:             return UIColor(theme.string)
118:             
119:         // Comments
120:         case "comment", "comment.line", "comment.block", "comment.documentation":
121:             return UIColor(theme.comment)
122:             
123:         // Functions and method calls
124:         case "function", "function.call", "function.method", "function.builtin",
125:              "method", "method.call":
126:             return UIColor(theme.function)
127:             
128:         // Types, classes, and type-like constructs
129:         case "type", "type.builtin", "type.definition", "type.qualifier",
130:              "class", "struct", "enum", "interface", "namespace":
131:             return UIColor(theme.type)
132:             
133:         // Variables and properties
134:         case "variable", "variable.parameter", "variable.member",
135:              "property", "property.definition", "field":
136:             return UIColor(theme.variable)
137:             
138:         // Variable builtins (self, this, super)
139:         case "variable.builtin", "variable.language":
140:             return UIColor(theme.keyword).withAlphaComponent(0.9)
141:             
142:         // Numbers and numeric constants
143:         case "number", "number.float", "float", "integer":
144:             return UIColor(theme.number)
145:             
146:         // Constants
147:         case "constant", "constant.builtin", "constant.character", "boolean":
148:             return UIColor(theme.number)
149:             
150:         // Constructors


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift", "start_line": 280, "end_line": 315}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift (lines 281-315 of 315)
────────────────────────────────────────
281: 
282: // MARK: - RunestoneThemeAdapter
283: 
284: /// Static helper for creating Runestone themes from our app's Theme struct
285: public enum RunestoneThemeAdapter {
286:     
287:     /// Creates a Runestone Theme from our app's Theme struct
288:     /// - Parameters:
289:     ///   - theme: The app's Theme to convert
290:     ///   - fontSize: Font size for the editor (default: 14)
291:     /// - Returns: A Runestone-compatible Theme
292:     public static func theme(from theme: Models.Theme, fontSize: CGFloat = 14) -> Runestone.Theme {
293:         VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
294:     }
295:     
296:     /// Creates a Runestone Theme from our app's Theme with customized settings
297:     /// - Parameters:
298:     ///   - theme: The app's Theme to convert
299:     ///   - fontSize: Font size for the editor
300:     /// - Returns: A VSCodeRunestoneTheme instance
301:     public static func createTheme(
302:         from theme: Models.Theme,
303:         fontSize: CGFloat = 14
304:     ) -> VSCodeRunestoneTheme {
305:         VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
306:     }
307: }
308: 
309: // MARK: - Theme Namespace Alias
310: 
311: /// Namespace alias to avoid conflicts between our Theme model and Runestone's Theme protocol
312: public enum Models {
313:     public typealias Theme = VSCodeiPadOS.Theme
314: }
315: 


Let me verify the Services directory structure:

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/
📁 NativeGit/
📁 OnDevice/
📁 Runners/
   AIManager.swift
   AutocompleteManager.swift
   CodeFoldingManager.swift
   ColorPickerManager.swift
   DebugManager.swift
   EditorCore.swift
   ErrorParser.swift
   FileSystemNavigator.swift
   GitManager.swift
   GitService.swift
   HoverInfoManager.swift
   InlayHintsManager.swift
   InlineSuggestionManager.swift
   KeychainManager.swift
   LaunchManager.swift
   NavigationManager.swift
   RecentFileManager.swift
   RemoteDebugger.swift
   RemoteRunner.swift
   RunestoneThemeAdapter.swift
   RunnerSelector.existing.swift
   RunnerSelector.swift
   SearchManager.swift
   SettingsManager.swift
   SFTPManager.swift
   SnippetsManager.swift
   SpotlightManager.swift
   SSHManager.swift
   SuggestionCache.swift
   TasksManager.swift
   ThemeManager.swift.bak
   TreeSitterLanguages.swift
   WindowStateManager.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift", "start_line": 280, "end_line": 320}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift (lines 281-315 of 315)
────────────────────────────────────────
281: 
282: // MARK: - RunestoneThemeAdapter
283: 
284: /// Static helper for creating Runestone themes from our app's Theme struct
285: public enum RunestoneThemeAdapter {
286:     
287:     /// Creates a Runestone Theme from our app's Theme struct
288:     /// - Parameters:
289:     ///   - theme: The app's Theme to convert
290:     ///   - fontSize: Font size for the editor (default: 14)
291:     /// - Returns: A Runestone-compatible Theme
292:     public static func theme(from theme: Models.Theme, fontSize: CGFloat = 14) -> Runestone.Theme {
293:         VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
294:     }
295:     
296:     /// Creates a Runestone Theme from our app's Theme with customized settings
297:     /// - Parameters:
298:     ///   - theme: The app's Theme to convert
299:     ///   - fontSize: Font size for the editor
300:     /// - Returns: A VSCodeRunestoneTheme instance
301:     public static func createTheme(
302:         from theme: Models.Theme,
303:         fontSize: CGFloat = 14
304:     ) -> VSCodeRunestoneTheme {
305:         VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
306:     }
307: }
308: 
309: // MARK: - Theme Namespace Alias
310: 
311: /// Namespace alias to avoid conflicts between our Theme model and Runestone's Theme protocol
312: public enum Models {
313:     public typealias Theme = VSCodeiPadOS.Theme
314: }
315: 


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/
📁 NativeGit/
📁 OnDevice/
📁 Runners/
   AIManager.swift
   AutocompleteManager.swift
   CodeFoldingManager.swift
   ColorPickerManager.swift
   DebugManager.swift
   EditorCore.swift
   ErrorParser.swift
   FileSystemNavigator.swift
   GitManager.swift
   GitService.swift
   HoverInfoManager.swift
   InlayHintsManager.swift
   InlineSuggestionManager.swift
   KeychainManager.swift
   LaunchManager.swift
   NavigationManager.swift
   RecentFileManager.swift
   RemoteDebugger.swift
   RemoteRunner.swift
   RunestoneThemeAdapter.swift
   RunnerSelector.existing.swift
   RunnerSelector.swift
   SearchManager.swift
   SettingsManager.swift
   SFTPManager.swift
   SnippetsManager.swift
   SpotlightManager.swift
   SSHManager.swift
   SuggestionCache.swift
   TasksManager.swift
   ThemeManager.swift.bak
   TreeSitterLanguages.swift
   WindowStateManager.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift
(cached)


The file was created successfully. Let me verify the middle section of the file as well:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift", "start_line": 150, "end_line": 250}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift (lines 151-250 of 315)
────────────────────────────────────────
151:         case "constructor":
152:             return UIColor(theme.function)
153:             
154:         // Operators and punctuation
155:         case "operator":
156:             return UIColor(theme.editorForeground)
157:             
158:         case "punctuation", "punctuation.bracket", "punctuation.delimiter",
159:              "punctuation.special":
160:             return UIColor(theme.editorForeground).withAlphaComponent(0.8)
161:             
162:         // Tags (HTML/XML)
163:         case "tag", "tag.builtin":
164:             return UIColor(theme.keyword)
165:             
166:         // Attributes
167:         case "attribute", "attribute.builtin":
168:             return UIColor(theme.function)
169:             
170:         // Labels
171:         case "label":
172:             return UIColor(theme.type)
173:             
174:         // Embedded code (like template literals)
175:         case "embedded":
176:             return UIColor(theme.string)
177:             
178:         default:
179:             // For unrecognized names, try to match by prefix
180:             return textColorByPrefix(highlightName)
181:         }
182:     }
183:     
184:     /// Attempts to find a color by checking highlight name prefixes
185:     private func textColorByPrefix(_ highlightName: String) -> UIColor? {
186:         if highlightName.hasPrefix("keyword") {
187:             return UIColor(theme.keyword)
188:         } else if highlightName.hasPrefix("string") {
189:             return UIColor(theme.string)
190:         } else if highlightName.hasPrefix("comment") {
191:             return UIColor(theme.comment)
192:         } else if highlightName.hasPrefix("function") || highlightName.hasPrefix("method") {
193:             return UIColor(theme.function)
194:         } else if highlightName.hasPrefix("type") || highlightName.hasPrefix("class") {
195:             return UIColor(theme.type)
196:         } else if highlightName.hasPrefix("variable") || highlightName.hasPrefix("property") {
197:             return UIColor(theme.variable)
198:         } else if highlightName.hasPrefix("number") || highlightName.hasPrefix("constant") {
199:             return UIColor(theme.number)
200:         }
201:         return nil
202:     }
203:     
204:     /// Normalizes a highlight name by converting it to lowercase and trimming whitespace
205:     private func normalizeHighlightName(_ name: String) -> String {
206:         name.lowercased().trimmingCharacters(in: .whitespaces)
207:     }
208:     
209:     /// Returns the font for a given highlight name (optional override)
210:     /// - Parameter highlightName: The Tree-sitter capture name
211:     /// - Returns: A custom font, or nil to use the default font
212:     public func font(for highlightName: String) -> UIFont? {
213:         // Use default font for all highlights - traits will modify it
214:         return nil
215:     }
216:     
217:     /// Returns font traits (bold, italic) for a given highlight name
218:     /// - Parameter highlightName: The Tree-sitter capture name
219:     /// - Returns: FontTraits to apply to the text
220:     public func fontTraits(for highlightName: String) -> FontTraits {
221:         let normalizedName = normalizeHighlightName(highlightName)
222:         
223:         switch normalizedName {
224:         // Keywords are bold
225:         case let name where name.hasPrefix("keyword"):
226:             return .bold
227:             
228:         // Comments are italic
229:         case let name where name.hasPrefix("comment"):
230:             return .italic
231:             
232:         // Type definitions can be bold
233:         case "type.definition", "class", "struct", "enum", "interface":
234:             return .bold
235:             
236:         // Storage modifiers (static, const, etc.) are italic
237:         case "storage", "storage.modifier":
238:             return .italic
239:             
240:         default:
241:             return []
242:         }
243:     }
244:     
245:     /// Returns a shadow for a given highlight name (optional)
246:     /// - Parameter highlightName: The Tree-sitter capture name
247:     /// - Returns: An NSShadow to apply, or nil for no shadow
248:     public func shadow(for highlightName: String) -> NSShadow? {
249:         // No shadows by default - can be customized if needed
250:         return nil


>>>REPORT
## PHASE 2 COMPLETE: RunestoneThemeAdapter.swift Created

### File Created
- **Path:** `VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift`
- **Lines:** 315

### Implementation Details

**1. VSCodeRunestoneTheme Class** (implements Runestone.Theme protocol)

Required properties mapped from our Theme struct:
- `font` → UIFont.monospacedSystemFont (configurable size)
- `textColor` → theme.editorForeground
- `gutterBackgroundColor` → theme.sidebarBackground
- `gutterHairlineColor` → theme.sidebarBackground with alpha
- `lineNumberColor` → theme.lineNumber
- `lineNumberFont` → monospacedSystemFont
- `selectedLineBackgroundColor` → theme.currentLineHighlight
- `selectedLinesLineNumberColor` → theme.lineNumberActive
- `selectedLinesGutterBackgroundColor` → theme.sidebarBackground
- `invisibleCharactersColor` → theme.lineNumber with 0.4 alpha
- `pageGuideHairlineColor` → theme.indentGuide
- `pageGuideBackgroundColor` → theme.editorBackground
- `markedTextBackgroundColor` → theme.selection

**2. textColor(for highlightName: String) → UIColor?**

Maps Tree-sitter highlight names to theme colors:
- `keyword*` → theme.keyword
- `string*` → theme.string
- `comment*` → theme.comment
- `function*`, `method*` → theme.function
- `type*`, `class`, `struct`, `enum` → theme.type
- `variable*`, `property*` → theme.variable
- `number*`, `constant*` → theme.number
- Plus fallback prefix matching for unrecognized names

**3. fontTraits(for highlightName: String) → FontTraits**

- Keywords → `.bold`
- Comments → `.italic`
- Type definitions → `.bold`
- Storage modifiers → `.italic`

**4. Additional Methods**
- `font(for:)` → returns nil (uses default)
- `shadow(for:)` → returns nil (no shadows)
- `highlightedRange(forFoundTextRange:ofStyle:)` → iOS 16+ search result highlighting

**5. Static Helper: RunestoneThemeAdapter**
```swift
RunestoneThemeAdapter.theme(from: Theme, fontSize: CGFloat) -> Runestone.Theme
RunestoneThemeAdapter.createTheme(from: Theme, fontSize: CGFloat) -> VSCodeRunestoneTheme
```

**6. Namespace Handling**
- Created `Models` enum with typealias to avoid conflicts between our `Theme` struct and Runestone's `Theme` protocol

### Sources Referenced
- `VSCodeiPadOS/VSCodeiPadOS/Models/Theme.swift` (lines 1-107) - Our Theme struct with all color properties
- Runestone GitHub repository Theme.swift - Protocol requirements
- Runestone FontTraits.swift - `.bold` and `.italic` options
- Runestone HighlightName.swift - Standard highlight name patterns
- Runestone DefaultTheme.swift - Example implementation pattern
>>>END
