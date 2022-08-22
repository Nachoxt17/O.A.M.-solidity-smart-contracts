Feature: Artwork decentralized autonomous organization

Background:
    Given we have a physical artwork
    And we have an valuation of the artwork
    And we have stored the artwork in our facility
    And we have insured the artwork for the amount of the valuation or more

    Examples: Artwork DAO configuration Data
    | Configuration         | Value |
    | Artwork name          | The Beast |
    | Artist                | Bjarne Melgaard |
    | Ticker name           | $AT22BM1 |
    | Token supply          | 10000 |
    | Token valuation       | 39.9 |
    | Token currency token  | $NOK tokens |
    | Artwork owner wallet  | 0xff43… |
    | Platform share        | 4.7% |
    | Platform wallet       | 0x2df3… |
    | ITO start             | in 7 days |
    | ITO end               | in 14 days |
    | Token release batches | 1 batch |
    | Token Transaction fee | 1 $NOK |
    | Artwork Owner fee     | 12.5% |
    | Artwork Invest fee    | 12.5% |
    | Artwork Acquire fee   | 12.5% |

    Scenario: Initiating the ArtWork DAO
        Given I am authenticated as a Platform Admin
        And I have the Artwork Configuration Data ready
        And I have the metadata JSON file configured
        Then I am allowed to mint the ArtWork DAO

        When I mint the ArtWork DAO

