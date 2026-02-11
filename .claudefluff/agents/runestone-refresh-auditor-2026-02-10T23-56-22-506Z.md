# Agent: runestone-refresh-auditor
**Status:** done
**Tokens:** 5,851
**Cost:** $0.0000
**Time:** 2026-02-10T23:56:22.506Z

## Task
URGENT: Investigate why newly typed text doesn't get syntax highlighted.

1. Read VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift
2. Find the Coordinator class and textViewDidChange delegate method
3. Check if Runestone automatically re-highlights on edit or if we need to trigger it
4. Look for any issues with setText() vs setState() calls
5. Report: Why doesn't new text get colored? What triggers re-highlighting?

## Response
I'll investigate the syntax highlighting issue by reading the relevant file.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift"}
>>>END

Now let me search for any Runestone documentation or how it handles incremental highlighting:

>>>TOOL web_search
{"query": "Runestone TextView TreeSitter incremental syntax highlighting automatic re-parse edit"}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone TextView TreeSitter incremental syntax highlighting automatic re-parse edit" (10 results):

1. **Adding a Tree-sitter Language - Documentation**
   https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/
   There is often a single parser for each language. A Tree-sitter parser takes text as input and outputs a syntax tree, a structure that describes the contents of that file. This tree is used by Runestone to understand the contents of a file and ultimately syntax highlight the file. Syntax highlighting is performed by querying the tree.

2. **Anyway to get the TreeSitterTree inside the textView? #103**
   https://github.com/simonbs/Runestone/issues/103
   Kaelzs commented Jun 23, 2022 Hello, I&#x27;m integrating the Runestone framework into my rule editor, and it&#x27;s awesome, especially the highlight and line number stuffs! And after integrating the syntax highlight, I try to do some analysis using the tree parsed by the tree-sitter, and I found the tree is stored in textView privately.

3. **Syntax Highlighting - Tree-sitter**
   https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html
   Syntax Highlighting Syntax highlighting is a very common feature in applications that deal with code. Tree-sitter has built-in support for syntax highlighting via the tree-sitter-highlight library, which is now used on GitHub.com for highlighting code written in several languages.

4. **Incremental Parsing | tree-sitter/tree-sitter | DeepWiki**
   https://deepwiki.com/tree-sitter/tree-sitter/2.4-incremental-parsing
   This document describes Tree-sitter&#x27;s incremental parsing system, which efficiently updates syntax trees when source code changes. The system reuses existing tree nodes where possible and only re-parses modified portions of the input, providing significant performance improvements for interactive editing scenarios.

5. **Syntax highlight anything with Tree-sitter - Programming for fun and profit**
   https://slar.se/syntax-highlight-anything-with-tree-sitter.html
   The flavor of the week is syntax highlighting. I&#x27;ve been using the highly customizable nvim-treesitter for the past few years. This depends on there being a Tree-sitter parser for whatever language you&#x27;re working with. Usually there is, but sometimes you run into languages that are esoteric enough that there aren&#x27;t any parsers available.

6. **Implementing a Syntax Highlighter with Tree-Sitter. | Brian&#x27;s Blog**
   http://brianmoniaga.com/Blog/posts/syntaxhighlighting/
   One of the most important part of a text editor is having a syntax highlighting system. As such, I began looking into different implementations of how one might achieve syntax highlighting. I narrowed down how I would achieve this with either one of: A Lexer (Using a pre-made library or build one myself). An Abstract Syntax Tree (Using Tree Sitter). In terms of a lexer, it would read the ...

7. **syntax highlighting with tree-sitter - Tony Finch**
   https://dotat.at/@/2025-03-30-hilite.html
   But for syntax highlighting I had to be able to find fenced code blocks. It was time to put some code into the pipeline between pulldown-cmark &#x27;s parser and renderer. And if I&#x27;m using a proper parser I can get rid of a few regexes: after some hacking, now only the YAML frontmatter is handled with a regex.

8. **Modern Tree-sitter, part 3: syntax highlighting via queries**
   https://blog.pulsar-edit.dev/posts/20231013-savetheclocktower-modern-tree-sitter-part-3/
   Syntax highlighting isn&#x27;t the only way that Tree-sitter&#x27;s query system can make our lives easier. In the next installment we&#x27;ll tackle two tasks that the legacy Tree-sitter integration never addressed: indentation and code folding.

9. **Syntax Highlighting the Text — Runestone Tutorials | Documentation**
   https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/
   Runestone Essentials Syntax Highlighting the Text This tutorial guides you through syntax highlighting text in a text view. In this guide we&#x27;ll add support for syntax highlighting JavaScript code to the text view we configured in Setting up a TextView. We&#x27;ll use the JavaScript syntax included in the TreeSitterLanguages Swift package.

10. **Incremental Parsing Using Tree-sitter - Strumenta**
   https://tomassetti.me/incremental-parsing-using-tree-sitter/
   A query uses a Lisp-like syntax (i.e, an S-expression) to define a pattern that, if matched, will make Tree-sitter assign the highlight name to the nodes. To indicate a node, you put its name between parentheses.


Let me check the Runestone documentation more specifically:

>>>TOOL web_fetch
{"url": "https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/    
| ✓ | ⏱: 0.94s 
[SCRAPE].. ◆ 
https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/    
| ✓ | ⏱: 0.00s 
[COMPLETE] ● 
https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/    
| ✓ | ⏱: 0.94s 
[Skip Navigation](https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/#main)
Light
Dark
Auto


Let me search the Runestone GitHub for more specific information about text changes and highlighting:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextView.swift", "use_crawl4ai": true, "max_length": 15000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextView.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextVi
ew.swift             | ✓ | ⏱: 1.36s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextVi
ew.swift             | ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextVi
ew.swift             | ✓ | ⏱: 1.39s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextView.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTextView%2FTextView.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTextView%2FTextView.swift)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTextView%2FTextView.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextView.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextView.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/TextView.swift) to refresh your session. Dismiss alert
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
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# TextView.swift
/
Copy path
404 - page not found
The 
main
branch of 
Runestone
does not contain the path 
Sources/Runestone/TextView/TextView.swift.
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


Let me search the Runestone repository structure:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone", "use_crawl4ai": true, "max_length": 10000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone                               
| ✓ | ⏱: 1.31s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone                               
| ✓ | ⏱: 0.07s 
[COMPLETE] ● https://github.com/simonbs/Runestone                               
| ✓ | ⏱: 1.38s 
[Skip to content](https://github.com/simonbs/Runestone#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. 
### License
[ ](https://github.com/simonbs/Runestone/blob/main/LICENSE)
[ 3k stars ](https://github.com/simonbs/Runestone/stargazers) [ 193 forks ](https://github.com/simonbs/Runestone/forks) [ Branches ](https://github.com/simonbs/Runestone/branches) [ Tags ](https://github.com/simonbs/Runestone/tags) [ Activity ](https://github.com/simonbs/Runestone/activity)
[ Star  ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
[ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
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


# simonbs/Runestone
main
[**3** Branches](https://github.com/simonbs/Runestone/branches)[**31** Tags](https://github.com/simonbs/Runestone/tags)
[](https://github.com/simonbs/Runestone/branches)[](https://github.com/simonbs/Runestone/tags)
Go to file
Code
Open more actions menu
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
## Latest commit
## History
[1,161 Commits](https://github.com/simonbs/Runestone/commits/main/) [](https://github.com/simonbs/Runestone/commits/main/)1,161 Commits  
[.github](https://github.com/simonbs/Runestone/tree/main/.github ".github") | [.github](https://github.com/simonbs/Runestone/tree/main/.github ".github") |  |   
[Assets](https://github.com/simonbs/Runestone/tree/main/Assets "Assets") | [Assets](https://github.com/simonbs/Runestone/tree/main/Assets "Assets") |  |   
[Design](https://github.com/simonbs/Runestone/tree/main/Design "Design") | [Design](https://github.com/simonbs/Runestone/tree/main/Design "Design") |  |   
[Example](https://github.com/simonbs/Runestone/tree/main/Example "Example") | [Example](https://github.com/simonbs/Runestone/tree/main/Example "Example") |  |   
[Scripts](https://github.com/simonbs/Runestone/tree/main/Scripts "Scripts") | [Scripts](https://github.com/simonbs/Runestone/tree/main/Scripts "Scripts") |  |   
[Sources](https://github.com/simonbs/Runestone/tree/main/Sources "Sources") | [Sources](https://github.com/simonbs/Runestone/tree/main/Sources "Sources") |  |   
[Tests/RunestoneTests](https://github.com/simonbs/Runestone/tree/main/Tests/RunestoneTests "This path skips through empty directories") | [Tests/RunestoneTests](https://github.com/simonbs/Runestone/tree/main/Tests/RunestoneTests "This path skips through empty directories") |  |   
[UITests](https://github.com/simonbs/Runestone/tree/main/UITests "UITests") | [UITests](https://github.com/simonbs/Runestone/tree/main/UITests "UITests")


Let me search for issues related to Runestone highlighting after editing:

>>>TOOL web_search
{"query": "Runestone simonbs syntax highlighting not working after edit site:github.com"}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone simonbs syntax highlighting not working after edit site:github.com" (10 results):

1. **Issues · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/issues
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - Issues · simonbs/Runestone

2. **Runestone - Performant plain text editor for iOS - GitHub**
   https://github.com/simonbs/runestone
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - simonbs/Runestone

3. **Blocking UI on closing bracket deletion in medium size TS file #132**
   https://github.com/simonbs/Runestone/issues/132
   As a note, Runestone does perform syntax highlighting in the background when scrolling the document but will intentionally perform syntax highlighting on the main thread when editing the document. The reason for performing syntax highlighting on the main thread is to avoid the text being incorrectly colored immediately after editing.

4. **Performant plain text editor for iOS with syntax ... - GitHub**
   https://github.com/bluescreenFTW/runestone
   Runestone uses GitHub&#x27;s Tree-sitter to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.

5. **After upgrading TreeSitterLanguages from 0.1.6 to 0.1.7 markdown is not ...**
   https://github.com/simonbs/Runestone/issues/259
   This allows me to render the bold markdown text as expected. However in 0.2.12 together with TreeSitterLanguages 0.1.7 the same input string in the text view is reported as punctuation.special. Therefore the highlighting code im my theme does not work as expected any more.

6. **simonbs (Simon B. Støvring) · GitHub**
   https://github.com/simonbs
   Pinned Runestone Public 📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. Swift 3k 193

7. **The editor will not respond in some cases #279 - GitHub**
   https://github.com/simonbs/Runestone/issues/279
   This seems to work well, but in some cases, after switching tabs, the editor will request the layout of the entire text. If the text is long (more than 10000 lines), the memory consumption may reach 1GB. What is the best way to implement a multi-tab editor? Under what circumstances will the editor rearrange all content?

8. **Example app using the StringSyntaxHighlighter in Runestone.**
   https://github.com/simonbs/RunestoneSnippetExample
   The app showcases the StringSyntaxHighlighter in Runestone, my open-source plain text editor for iOS, iPadOS, and visionOS. The StringSyntaxHighlighter can be used to syntax highlight a string without needing to create a TextView.

9. **GitHub - shaneholloman/runestone: Performant plain text editor for ...**
   https://github.com/shaneholloman/runestone
   Runestone uses GitHub&#x27;s Tree-sitter to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.

10. **Anyway to get the TreeSitterTree inside the textView? #103**
   https://github.com/simonbs/Runestone/issues/103
   I&#x27;ve written my own Tree-sitter grammar for that and am using Runestone as the in-app editor for syntax highlighting. I also have some light-weight autocompletion in that editor, which would benefit a lot from having access to the tree generated for formulas from the same Tree-sitter grammar.


Let me look at the Runestone issue #132 for more context:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/issues/132", "use_crawl4ai": true, "max_length": 8000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/issues/132

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/issues/132                    
| ✓ | ⏱: 1.52s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/issues/132                    
| ✓ | ⏱: 0.03s 
[COMPLETE] ● https://github.com/simonbs/Runestone/issues/132                    
| ✓ | ⏱: 1.55s 
[Skip to content](https://github.com/simonbs/Runestone/issues/132#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fissues%2F132)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fissues%2F132)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fvoltron%2Fissues_fragments%2Fissue_layout&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/issues/132) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/issues/132) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/issues/132) to refresh your session. Dismiss alert
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


#  Blocking UI on closing bracket deletion in medium size TS file #132
[New issue](https://github.com/login?return_to=https://github.com/simonbs/Runestone/issues/132)
Copy link
[New issue](https://github.com/login?return_to=https://github.com/simonbs/Runestone/issues/132)
Copy link
[#134](https://github.com/simonbs/Runestone/pull/134)
[Blocking UI on closing bracket deletion in medium size TS file](https://github.com/simonbs/Runestone/issues/132#top)#132
[#134](https://github.c


Now I have enough information to provide a comprehensive report.

>>>REPORT
## Syntax Highlighting Investigation: Why New Text Doesn't Get Colored

### Key Findings

**Location:** `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift`

#### 1. Coordinator & textViewDidChange (Lines 320-454)

The `textViewDidChange` delegate method (lines 350-375):
```swift
func textViewDidChange(_ textView: TextView) {
    // Mark that user has edited - blocks setState() calls until file switch
    hasBeenEdited = true
    
    // Cancel any pending debounced update
    textSyncWorkItem?.cancel()
    
    // Create new debounced work item (syncs text to SwiftUI binding)
    let workItem = DispatchWorkItem { ... }
    // ... schedules parent.text = textView.text after 500ms
}
```

**Critical observation:** The `textViewDidChange` method does NOT manually trigger re-highlighting. It only syncs text to the SwiftUI binding.

#### 2. How Runestone Highlighting SHOULD Work

Per Runestone issue #132, the library maintainer confirms:
> "Runestone does perform syntax highlighting on the main thread when editing the document. The reason for performing syntax highlighting on the main thread is to avoid the text being incorrectly colored immediately after editing."

**Runestone automatically handles incremental TreeSitter re-parsing and re-highlighting internally.** There's no need to call any external trigger function - it's built into the `TextView` class.

#### 3. setState() vs text Property (Lines 110-116, 168-175)

The code uses two different approaches:
- **With language:** `textView.setState(TextViewState(text: text, language: language))` - enables TreeSitter
- **Without language:** `textView.text = text` - plain text, NO highlighting

#### 4. Root Cause Analysis

**The issue is NOT missing re-highlight calls.** Runestone handles that internally.

Possible causes:
1. **Language not detected:** `getTreeSitterLanguage(for:)` (lines 234-299) returns `nil` for many extensions (TypeScript only falls back to JavaScript, many languages return nil)
   
2. **Theme highlight name mismatches:** The `textColor(for:)` method (lines 586-680) may not recognize all TreeSitter highlight names. Returns `nil` (default text color) for unmatched names.

3. **Debug logging exists but may be disabled:** Line 592-594 has DEBUG prints:
   ```swift
   #if DEBUG
   print("🎨 Highlight: \(rawHighlightName)")
   #endif
   ```
   Check console for these to see what highlight names TreeSitter sends.

#### 5. What Triggers Re-highlighting

- **Runestone handles it automatically** when text changes via the text input system
- TreeSitter incrementally updates the syntax tree
- The theme's `textColor(for:)` is called for each syntax node
- No manual intervention needed IF the language was set via `setState()`

### Recommendation

**To debug:** Enable the DEBUG logging and check console for `🎨 Highlight:` messages when typing.

- If NO messages appear → TreeSitter language wasn't set (check file extension mapping)
- If messages appear but wrong colors → `textColor(for:)` isn't mapping the highlight names correctly

**Most likely fix:** The TreeSitter language may not be properly set for certain file types, or there's a mismatch between what TreeSitter emits and what the theme recognizes.
>>>END
