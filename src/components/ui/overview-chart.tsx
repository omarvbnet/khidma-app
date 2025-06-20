import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"

interface OverviewProps {
  data: {
    date: string
    count: number
  }[]
}

export function Overview({ data }: OverviewProps) {
  return (
    <ResponsiveContainer width="100%" height={350}>
      <LineChart data={data}>
        <XAxis
          dataKey="date"
          stroke="#888888"
          fontSize={12}
          tickLine={false}
          axisLine={false}
        />
        <YAxis
          stroke="#888888"
          fontSize={12}
          tickLine={false}
          axisLine={false}
          tickFormatter={(value) => `${value}`}
        />
        <Tooltip />
        <Line
          type="monotone"
          dataKey="count"
          stroke="#8884d8"
          strokeWidth={2}
          activeDot={{ r: 8 }}
        />
      </LineChart>
    </ResponsiveContainer>
  )
} 