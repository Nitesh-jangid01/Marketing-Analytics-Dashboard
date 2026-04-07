USE Client;

--------------------RelationShip
-- Campaigns -> Client
ALTER TABLE campaigns
ADD CONSTRAINT fk_client
FOREIGN KEY (client_id)
REFERENCES clients(client_id);

-- Campaign Performance -> Campaigns
ALTER TABLE campaign_performance
ADD CONSTRAINT fk_campaign
FOREIGN KEY (campaign_id)
REFERENCES campaigns(campaign_id);

-- Campaign Performance -> Channels
ALTER TABLE campaign_performance
ADD CONSTRAINT fk_channel
FOREIGN KEY (channel_id)
REFERENCES channels(channel_id);

-- Influencer Campaigns -> Influencers
ALTER TABLE influencer_campaigns
ADD CONSTRAINT fk_influencer
FOREIGN KEY (influencer_id)
REFERENCES influencers(influencer_id);




-- 1. Get all campaigns with client names.
	SELECT 
	cl.Client_name, 
	camp.campaign_name
	FROM
	dbo.clients AS cl
	JOIN dbo.campaigns AS camp
		ON cl.client_id = camp.client_id
	ORDER BY cl.client_name;

-- 2. Total spend per client.
	SELECT
	cl.client_name,
	SUM(cp.spend) AS Total_spend
	FROM
	dbo.clients AS cl
	JOIN dbo.campaigns AS camp
		ON cl.client_id = camp.client_id
	JOIN dbo.campaign_performance AS cp
		ON camp.campaign_id = cp.campaign_id
	GROUP BY cl.client_name;

-- 3. Channel performance
	SELECT
	ch.channel_name,
	SUM(cp.conversions) AS conversions
	FROM
	dbo.channels AS ch
	JOIN
	dbo.campaign_performance AS cp
		ON ch.channel_id = cp.channel_id
	GROUP BY ch.channel_name
	ORDER BY conversions DESC;

-- 4. ROI per campaign
	SELECT
	camp.campaign_name,
	SUM(cp.conversions) / SUM(cp.Spend) AS ROI
	FROM dbo.campaigns AS camp
	JOIN dbo.campaign_performance AS cp
		ON camp.campaign_id = cp.campaign_id
	GROUP BY camp.campaign_name
	ORDER BY ROI DESC;

-- 5. Best influencer per campaign
	SELECT
	camp.campaign_name,
	i.name,
	ic.conversions
	FROM
	dbo.campaigns AS camp
	JOIN dbo.influencer_campaigns AS ic
		ON camp.campaign_id = ic.campaign_id
	JOIN dbo.influencers AS i
		ON ic.influencer_id = i.influencer_id
	ORDER BY ic.conversions DESC;

-- 6. Full performance dashboard query
	SELECT
	cl.client_name,
    c.campaign_name,
    SUM(p.spend) AS total_spend,
    SUM(p.conversions) AS total_conversions,
    SUM(p.clicks) AS total_clicks
	FROM
	dbo.campaigns AS c
	JOIN dbo.clients AS cl
		ON c.client_id = cl.client_id
	JOIN dbo.campaign_performance AS p
		ON c.campaign_id = p.campaign_id
	GROUP BY cl.client_name, c.campaign_name;

-- 7. Top 3 campaigns per client
	WITH ranked AS (
    SELECT
    c.campaign_name,
    cl.client_name,
    SUM(p.conversions) AS Total_conversions,
    RANK() OVER (PARTITION BY cl.client_name ORDER BY SUM(p.conversions) DESC) AS rank
    FROM dbo.campaigns AS c
    JOIN dbo.clients AS cl
        ON c.client_id = cl.client_id
    JOIN dbo.campaign_performance AS p
        ON c.campaign_id = p.campaign_id
    GROUP BY c.campaign_name, cl.client_name
	)
	SELECT *
	FROM ranked
	WHERE rank <= 3;
------------------------------ OR
	SELECT *
	FROM (
		SELECT 
        cl.client_name,
        c.campaign_name,
        SUM(p.conversions) AS conversions,
        RANK() OVER (PARTITION BY cl.client_name ORDER BY SUM(p.conversions) DESC) AS rank
		FROM clients cl
		JOIN campaigns c 
			ON cl.client_id = c.client_id
		JOIN campaign_performance p 
			ON c.campaign_id = p.campaign_id
		GROUP BY cl.client_name, c.campaign_name
	) r
WHERE rank <= 3;

