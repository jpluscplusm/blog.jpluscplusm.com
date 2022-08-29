---
title: Modelling corporation tax in beancount
date: 2022
---

# DRAFT: this unfinished article is a work in progress!

Here in the UK, "limited" companies are usually required to pay [the UK government's tax authority, HMRC](https://www.gov.uk/government/organisations/hm-revenue-customs), a proportion of their profits, called "Corporation Tax".

There.
That's the sum total of the accounting, legal, regulatory or statutory advice that this page contains, taken straight from [the government's website about corporation tax](https://www.gov.uk/corporation-tax).
**Absolutely all the rest of this page** contains the personal opinions of definitely-not-an-accountant who is **also** definitely-not-a-lawyer.
If you use these opinions and get into any kind of trouble, that's your problem, not mine!

(If you'd like a personal recommendation of an excellent accountancy firm, I'll happily point you towards [Maslins](https://www.maslins.co.uk/), whose services my own company has gladly paid for over several years.
If you tell them Jonathan sent you then I'll save a small amount of money, with which I'll buy you a pint and/or coffee :-)
For the record, **this page is *wholly* not related to, not reviewed by, and not requested by Maslins**, and I'm sure their first advice would be "**please ignore *everything* Jonathan writes about accounting**"!)

With those disclaimers out of the way, here's what the rest of this page will cover.

We're going to look at some different ways that the plain text accounting tool "beancount" can be used to model and track the amount of corporation tax that a hypothetical limited company owes to HMRC.
These ideas will sit in different places on a number of spectra, include such riveting nuances as each method's:

- operational burden (the day-to-day recording effort involved)
- maintenance burden (the effort involved if something changes with what the company wants, or is required, to do)
- fidelity (how accurate it is, over what timescales)
- Accountant-Acceptance-Factor (why an actual, professional accountant might dislike it)

Let's begin by setting the scene, and establishing a common baseline for the rest of this page, by outlining the company's history and current position.

## CSL: "CDD Systems Limited"

Our hypothetical company is "CDD Systems Limited", which we'll refer to as "CSL".
Cat Driven Development (CDD) was the hot tech craze of 2016, involving:

- putting cats near computers, then
- sitting humans down as if they wanted to *use* those computers, and
- taking advantage of the cats' burning desire to walk over the computer keyboards, by then
- shipping the resulting code the cats produce.

CSL was founded in October 2016, so [its annual year end date is October 31st](https://companieshouse.blog.gov.uk/2015/12/23/a-guide-to-accounting-reference-dates-and-periods/).
The company has made decent money from promoting CDD as a practice, mostly because employee salary costs are low due to cats' unwillingness to unionise.
Tech workers: [join a union!](https://twitter.com/edent/status/1555161691918405632)

Each month during its first 3 years, CSL made exactly 1,000 GBP in sales revenue.
This awesome revenue consistency has been because cats, as we all know, are both extremely conscientious, and love doing exactly the same thing, each day, without complaint, and definitely never change their minds about which foods they'll eat even when you've just bought a bloody crate of the stuff for goodness' sake, Tiger, you ornery little blighter.

We'll initially record these sales as a single transaction, on the last day of each financial year, because we're lazy.

But that 12,000 GBP in sales isn't entirely profit - there were *some* expenses.

Each month, the company has to spend 750 GBP on cat food, 50 GBP on vet bills, and 20 GBP on mice.
Again, because we're lazy, we'll track each year's expenditure in a single transaction on the last day of each company year.

So that's 3 *excellent* years for the company: FY2017 (the company's Financial Year that ended in 2017, on 31 October), FY2018 and FY2019.

Then, in March 2020, the world changed significantly.

As we've all experienced, the pandemic changed what we thought of as "normal".
We've spent a lot more time at home than we expected.

Those of us in tech who have been lucky enough to continue *working* from home have come to realise one, inescapable truth: **cats have no interest in working remotely**.

The amazing effectiveness of CDD, Cat Driven Development, took a huge hit.
Because we've had to be socially isolated from our feline colleagues, the cats had no reason to keep walking over the computer keyboards without any humans nearby.
CSL's productivity dropped off a cliff.
Our company lost all its clients, 5 months into its FY2020.

And, whilst different governments have responded to this economic challenge in different ways, the UK government intentionally excluded cats from its [CJRS support scheme](https://www.gov.uk/government/collections/coronavirus-job-retention-scheme).
With no sales revenue and no government support, CSL's monthly income dropped to zero from April 2020 onwards but its outgoing expenses remained the same - we still have the same number of cats to feed and take care of.

Let's describe that situation in beancount's journal format, and see what beancount's *excellent* GUI, Fava, looks like when we show it this baseline:

- [CDD_Systems_Limited-baseline.beancount](CDD_Systems_Limited-baseline.beancount)

```beancount
; the 4 next lines are boilerplate, which we'll omit from journals in the future
option "title" "CDD Systems Limited"
option "operating_currency" "GBP"
plugin "beancount.plugins.auto_accounts"
2000-01-01 custom "fava-option" "fiscal-year-end" "10-31"

2017-10-31 * "Sales"
	Income:Sales         -(1,000 * 12) GBP
	Assets:Bank           (1,000 * 12) GBP
2017-10-31 * "Expenses"
	Expenses:Food         (750 * 12) GBP
	Expenses:Healthcare   ( 50 * 12) GBP
	Expenses:Mice         ( 20 * 12) GBP
	Assets:Bank          -((750+50+20) * 12) GBP

2018-10-31 * "Sales"
	Income:Sales         -(1,000 * 12) GBP
	Assets:Bank           (1,000 * 12) GBP
2018-10-31 * "Expenses"
	Expenses:Food         (750 * 12) GBP
	Expenses:Healthcare   ( 50 * 12) GBP
	Expenses:Mice         ( 20 * 12) GBP
	Assets:Bank          -((750+50+20) * 12) GBP

2019-10-31 * "Sales"
	Income:Sales         -(1,000 * 12) GBP
	Assets:Bank           (1,000 * 12) GBP
2019-10-31 * "Expenses"
	Expenses:Food         (750 * 12) GBP
	Expenses:Healthcare   ( 50 * 12) GBP
	Expenses:Mice         ( 20 * 12) GBP
	Assets:Bank          -((750+50+20) * 12) GBP

2020-10-31 * "Sales for November - March"
	Income:Sales         -(1,000 * 5) GBP
	Assets:Bank           (1,000 * 5) GBP
2020-10-31 * "Expenses for the whole year"
	Expenses:Food         (750 * 12) GBP
	Expenses:Healthcare   ( 50 * 12) GBP
	Expenses:Mice         ( 20 * 12) GBP
	Assets:Bank          -((750+50+20) * 12) GBP

2021-10-31 * "Expenses for the whole year"
	Expenses:Food         (750 * 12) GBP
	Expenses:Healthcare   ( 50 * 12) GBP
	Expenses:Mice         ( 20 * 12) GBP
	Assets:Bank          -((750+50+20) * 12) GBP
```

Here's Fava's Income Statement view of those 5 complete years (remember, in Plain Text Accounting, money coming in to Income accounts is represented as negative, and profit is negative if you made money):

[![Fava Income Statement screenshot](screenshot-1.png)](screenshot-1.png)

And here's the Balance Sheet view:

[![Fava Balance Sheet screenshot](screenshot-2.png)](screenshot-2.png)

Let's move on to our first corporation tax modelling method: **not bothering to model corporation tax**.

## Method 1: Tracking Corporation Tax By Not Tracking Corporation Tax

Corporation tax liabilities are normally due for payment 9 months after a company's year ends.
So, in the 9 months following each year in which CSL makes a profit, we'll presumably remember to pay HMRC what we owe.
The transaction will appear in our bank statement and we'll categorise it appropriately, the next time we import our bank statements into beancount.
This is **method #1: simply record the concrete payments of corporation tax liabilities as expenses, as they happen, with no extra tracking**.

Whilst it's simple to understand and implement, we'll see that this method brings significant disadvantages, and also fails to make the company's performance as clear as we might wish.

Since 2017, the amount a company owes in corporation tax has been [19% of its profits, after allowable expenses have been taken into account](https://www.gov.uk/government/publications/rates-and-allowances-corporation-tax/rates-and-allowances-corporation-tax).

So our position for FY2017, FY2018, and FY2019 is easy to detail: we made a payment from the company bank account *sometime* in the 9 months after each year's end, for 19% of our relevant profit for the specific year.
Because those 3 years were identical, and we know from the [Fava Income Statement scoped to 2017 only](screenshot-3.png) that our annual profit was 2,160 GBP, we can calculate our 19% corporation tax liability as being 410.40 GBP each year:

[![Fava 2017 Balance Sheet screenshot](screenshot-3.png)](screenshot-3.png)

But in FY2020 and FY2021 (the company's Financial Years ending in (October) 2020 and 2021), the company didn't make a profit.
It made a loss.

We have a choice to make about what to do with those losses.
Each loss-making year, we *could* choose to [carry forward a trading loss](https://www.gov.uk/guidance/carry-forward-corporation-tax-losses) to future years, where it will be **offset against future profits, thereby reducing our corporation tax liability in the future**.
Or, if we made a profit *last* year, we could [carry back a trading loss](https://www.gov.uk/guidance/corporation-tax-calculating-and-claiming-a-loss#carry-a-trading-loss-back) and effectively get a **refund of up to the total amount of corporation tax that the company paid *last* year**.
But our ability to carry that loss back is limited to 1 year.
We can't get a refund of a corporation tax liability from more than 1 year ago.

Our FY2020 loss is visible in the [Fava Income Statement scoped to 2020](screenshot-4.png): 4,840 GBP

[![Fava 2020 Balance Sheet screenshot](screenshot-4.png)](screenshot-4.png)

Our FY2021 loss is also visible in Fava, and is trivial to calculate as the company had no income all year.
Thus, the loss is exactly equal to all the standard expenses we incurred: 9,840 GBP.

Our profit in FY2019 allows us to carry the FY2020 loss back, and get a refund of the smaller of 19% of the value of the FY2020 loss or 19% of the FY2019 profit.
In this instance, the FY2019 profit was smaller, so our refund is capped at 19% of that value.
We can only receive a direct refund of 410.40 GBP (relating to a loss of 2,160 GBP), with the remainder of the loss being carried *forward*.
So, Sometime after we filed our accounts with HMRC, they sent us the 410.40 GBP refund.

Because beancount's journals are date-ordered, not line-ordered, the relative position of the transaction categorising each year's tax liability payment is unimportant.
Beancount will sort all the transactions by date, for us.

This means that to deal with FY2017-FY2019 we can take [the baseline file shown above](CDD_Systems_Limited-baseline.beancount) and simply append these 3 transactions at the bottom:

```
2017-12-15 * "HMRC" "Corporation tax liability"
	Expenses:CorporationTax   410.40 GBP
	Assets:Bank              -410.40 GBP
2019-03-09 * "HMRC" "Corporation tax liability"
	Expenses:CorporationTax   410.40 GBP
	Assets:Bank              -410.40 GBP
2019-12-15 * "HMRC" "Corporation tax liability"
	Expenses:CorporationTax   410.40 GBP
	Assets:Bank              -410.40 GBP
```

The FY2020 loss' refund of 410.40 GBP can be dealt with as exactly the opposite transaction, when it hits our bank account (notice the signs are reversed):

```
2020-12-15 * "HMRC" "Corporation tax refund"
	Expenses:CorporationTax  -410.40 GBP
	Assets:Bank               410.40 GBP
```

But what about the leftover, un-carried-back loss from FY2020?
And the full FY2021 loss?

Using this method, both of these are untracked -- hence invisible -- in the [CDD_Systems_Limited-method_1-no_modelling.beancount](CDD_Systems_Limited-method_1-no_modelling.beancount) journal file and its Fava visualisation.

But that's not the only disadvantage of this method.

First, let's take a look at the new 5-year Income Statement view that Fava gives us, once these Corporation Tax payments are included:

[![Fava Income Statement screenshot](screenshot-5.png)](screenshot-5.png)

Notice how we see different bar chart heights for 2017, 2018 and 2019, despite all 3 of these years having identical underlying company performance.

We've also mixed the payment of corporation tax into the pool of expenses that are legitimately allowed to *reduce* the amount of corporation tax that's due, meaning we don't have:

- a clear view of the profit (or loss) that we made in any specific company year; or
- an obvious way to *calculate* the profit (or loss) for a specific year; or
- a pre-calculated corporation-tax-owed figure for any year.

Put simply, because corporation tax is not *itself* an allowable expense for corporation tax *relief*, and because we've lumped it in with all the other expenses that *are* allowable, we don't end up with a Fava view that helps us run the business.

Next, here's the "Changes" view (i.e. the period-to-period delta) when we're zoomed in to just the `Expenses:CorporationTax` account:

[![Fava single-account screenshot](screenshot-6.png)](screenshot-6.png)

Here, we:

- appear not to have paid anything in 2018; and 
- appear to have paid double in 2019 what we paid in 2017; and
- don't see a complete record of the FY2020 and FY2021 losses, apart from the insufficient FY2020 refund, as mentioned above.

The "missing" 2018 payment is simply because we delayed making the 2018 payment until after 2019 had started - a perfectly acceptable choice to make, given our 9 month window for payment.
Thus, the payment of the FY2018 liability appears in the calendar year 2019, doubling the height of the total amount paid in 2019.

Lastly, let's examine the Balance Sheet view:

[![Fava Balance Sheet screenshot](screenshot-7.png)](screenshot-7.png)

This graph shows us the Net Worth of the company, automatically combining assets and liabilities, over time.
The figures in the Equity table shows us the Net Worth at the end of the time period we've selected - which in this case is "all time for which the company has records".
(Let's ignore the fact that the company appears to be insolvent on the right hand edge of the graph!)

Our final problem is that the Net Worth graph doesn't actually reflect the true Net Worth of the company.
Every sale we make goes straight onto our books as income, and overestimates our Net Worth by not reflecting the extra corporation tax that's now due.
Each expense we incur (*except* the corporation tax expense itself) underestimates our Net Worth by not reflecting the corporation tax relief that the expense attracts.

Method #1, a.k.a. "just import the company's bank statements and track its concrete transactions", has significant disadvantages.
Using it, we don't know the actual book value -- the true Net Worth -- of the company at any point.

Method #1 is essentially (ok, not *quite*!) the beancount expression of [cash-basis accounting](https://en.wikipedia.org/wiki/Cash_method_of_accounting), with all its inherent disadvantages.
Using it, we have to calculate our corporation tax liability *outside* beancount, and remember to pay HMRC.

But that's not the way that computers are meant to work!
They're supposed to remember things -- and do calculations -- for us!

I believe method #1 shouldn't be used in practise, even when merely tracking company books as a paper exercise.

Let's move on to method #2: **tracking corporation tax once a year, as a liability**.

## Method 2: Tracking Corporation Tax Once A Year, As A Liability

[WIP]
